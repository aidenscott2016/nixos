---
name: home-assistant
description: Interact with the Home Assistant instance on gila.sw1a1aa.uk. Use when managing HA config, automations, ZHA devices, dashboards, lights, or any home automation task. Covers REST API, WebSocket API, config file editing, and ZHA Zigbee operations.
---

# Home Assistant

## Connection Details

- **Host**: `gila.sw1a1aa.uk`
- **URL**: `https://hass.sw1a1aa.uk`
- **API Token**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIwOTg3MmI1NGI4MzU0NzdjYWRlMWVhNGU1ZjczN2U3MiIsImlhdCI6MTc3MzA0Nzk2MywiZXhwIjoyMDg4NDA3OTYzfQ.GA2elYvQKEF9Vdqu1Op1uNV4JQLMFZIsdFREiRXYt6s`
- **Container**: `home-assistant` (Podman, managed by `podman-home-assistant.service`)
- **Config volume**: `/var/lib/containers/storage/volumes/home-assistant/_data/`

## REST API

```bash
HA_TOKEN="<token>"
BASE="https://hass.sw1a1aa.uk/api"

# Check status
curl -s "$BASE/config" -H "Authorization: Bearer $HA_TOKEN" | jq '{version, state}'

# Get entity state
curl -s "$BASE/states/light.anglepoise_light" -H "Authorization: Bearer $HA_TOKEN"

# Call service
curl -s -X POST "$BASE/services/light/turn_on" \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.example", "brightness": 254}'

# Evaluate template
curl -s -X POST "$BASE/template" \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"template": "{{ states(\"light.bedroom\") }}"}'

# Reload automations (no restart needed)
curl -s -X POST "$BASE/services/automation/reload" \
  -H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json"
```

## WebSocket API

Required for ZHA operations, device registry, repairs, and event subscriptions. Use Python with `websockets`:

```python
import asyncio, json, websockets

async def ws_call():
    uri = "wss://hass.sw1a1aa.uk/api/websocket"
    async with websockets.connect(uri) as ws:
        await ws.recv()  # auth_required
        await ws.send(json.dumps({"type": "auth", "access_token": TOKEN}))
        await ws.recv()  # auth_ok

        await ws.send(json.dumps({"id": 1, "type": "zha/devices"}))
        raw = await ws.recv()
        print(json.loads(raw))

asyncio.run(ws_call())
```

Run with: `nix-shell -p python3 python3Packages.websockets --run 'python3 /tmp/script.py'`

Write scripts to `/tmp/` — don't inline Python in heredocs (quoting issues with Jinja templates).

### Key WebSocket Commands

| Command | Purpose |
|---------|---------|
| `zha/devices` | List all Zigbee devices |
| `zha/devices/bind` | Bind device clusters (source_ieee, target_ieee) |
| `zha/devices/unbind` | Unbind device clusters |
| `zha/devices/reconfigure` | Reconfigure device (ieee) |
| `zha/groups` | List ZHA groups |
| `config/device_registry/list` | List all HA devices |
| `config/device_registry/update` | Update device (device_id, area_id, name_by_user) |
| `config/area_registry/list` | List areas |
| `repairs/list_issues` | List repair issues |
| `subscribe_events` | Subscribe to all events (useful for debugging) |

## Config File Editing

Config files are inside the Podman volume. Cannot SCP directly — must stage via `/tmp/`:

```bash
# Read
ssh gila.sw1a1aa.uk 'sudo cat /var/lib/containers/storage/volumes/home-assistant/_data/configuration.yaml'

# Edit (copy out → modify → copy back)
ssh gila.sw1a1aa.uk 'sudo cp .../_data/automations.yaml /tmp/automations.yaml && sudo chmod 644 /tmp/automations.yaml'
scp gila.sw1a1aa.uk:/tmp/automations.yaml /tmp/automations.yaml
# ... edit locally with StrReplace ...
ssh gila.sw1a1aa.uk 'sudo rm -f /tmp/automations.yaml'
scp /tmp/automations.yaml gila.sw1a1aa.uk:/tmp/automations.yaml
ssh gila.sw1a1aa.uk 'sudo cp /tmp/automations.yaml .../_data/automations.yaml'
```

### Key Config Files

| File | Purpose | Reload method |
|------|---------|---------------|
| `configuration.yaml` | Main config, template entities, input helpers | Restart required |
| `automations.yaml` | Automations | `automation/reload` service |
| `scenes.yaml` | Scenes | `scene/reload` service |
| `.storage/lovelace` | Dashboard (JSON) | Browser refresh |
| `.storage/core.area_registry` | Areas (JSON) | Restart required |
| `.storage/core.device_registry` | Device areas/names (JSON) | Restart required |
| `.storage/lovelace_resources` | Custom frontend cards (JSON) | Restart required |

### Restarting HA

```bash
# Restart container (config changes that need restart)
ssh gila.sw1a1aa.uk 'sudo systemctl restart podman-home-assistant'

# Wait for full startup (~60s)
sleep 60
curl -s "$BASE/config" -H "Authorization: Bearer $HA_TOKEN" | jq '.state'
# Must show "RUNNING" (not "NOT_RUNNING")
```

Never restart during firmware updates or active builds.

## Known Gotchas

### HA 2026.3+ Breaking Changes

- **`color_temp` (mireds) removed from service calls** — use `color_temp_kelvin` instead. Convert: `kelvin = 1000000 / mireds`.
- **Legacy `light.template` platform deprecated** — use the new `template:` integration:

```yaml
# Old (broken in 2026.3+)
light:
  - platform: template
    lights:
      bedroom:
        friendly_name: "Bedroom"
        turn_on:
          service: light.turn_on

# New
template:
  - light:
      - name: "Bedroom"
        turn_on:
          - action: light.turn_on
```

- `service:` → `action:` in the new template format.

### Zigbee / ZHA

- **Battery remotes (EndDevices) are sleepy** — bind/unbind commands are queued and delivered on next wake (button press). Send the command, then ask the user to press buttons.
- **Philips Hue RWL022** sends BOTH custom cluster events (`0xfc00`) AND standard ZCL commands (`0x0006` On/Off, `0x0008` Level Control). The standard ZCL commands can directly control nearby lights. Fix: bind the remote's output clusters to the coordinator via `zha/devices/bind`.
- **`zha/devices/unbind` returns `success: true`** even if the target device didn't process the request (it just means the coordinator accepted the message).
- **Touchlink** can create direct pairings between Hue remotes and nearby bulbs, bypassing HA entirely. HA logbook won't show these actions. Cannot be disabled in firmware.
- **`remove_all` groups command**: Send via `zha.issue_zigbee_cluster_command` — cluster 4, command 4, endpoint 1.
- **`jq` and `python3` are not installed on gila** — use `nix-shell -p jq --run '...'` or `nix-shell -p python3 --run '...'`.

### Event Debugging

Subscribe to all events via WebSocket and filter for `zha_event`, `state_changed`, and `call_service` to trace what happens on button presses. Useful for diagnosing direct Zigbee control vs automation-triggered actions.

## Areas

| Area | ID | Contents |
|------|----|----------|
| Bedroom | `bedroom` | Main lights, remote, sensors |
| Bedroom Ambient | `bedroom_ambient` | Lava lamps, smart plugs |
| Kitchen | `kitchen` | Sonoff |
| Garden | `garden` | Sonoff |
| Office | `office` | Switch |

## Custom Frontend

- **HACS** installed at `custom_components/hacs/`
- **auto-entities** card at `www/community/auto-entities.js`, registered in `lovelace_resources`
