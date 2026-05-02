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
- **Hue RWL022 hold events fire repeatedly during a hold** (~every 2s) and the `dustins/zha-philips-hue-v2-smart-dimmer-switch-and-remote-rwl022` blueprint runs `Power_HoldPress` on every fire. A 5-second hold = 2-3 action runs. Make hold actions idempotent (e.g. plain `light.turn_off` rather than scenes/scripts that compound).
- **`zha/devices/unbind` returns `success: true`** even if the target device didn't process the request (it just means the coordinator accepted the message).
- **Touchlink** can create direct pairings between Hue remotes and nearby bulbs, bypassing HA entirely. HA logbook won't show these actions. Cannot be disabled in firmware.
- **`zha.issue_zigbee_cluster_command` arg shape**: use `params` (a dict keyed by zigpy field names), not `args`. E.g. `remove_all` groups = `{cluster_id:4, command:4, command_type:"server", params:{}}`; `get_membership` = `params:{groups:[]}` (field is `groups`, not `group_list`).
- **Removing a ZHA device cleanly**: `zha.remove` REST service with `{"ieee":"<addr>"}` — works even when the device is disabled or unreachable. The `device_registry/remove_config_entry` WS path does not work for ZHA ("Config entry does not support device removal").
- **`jq` and `python3` are not installed on gila** — use `nix-shell -p jq --run '...'` or `nix-shell -p python3 --run '...'`.

### IKEA TRADFRI bulbs

- **`light.turn_off` *with* `transition:` on an already-off TRADFRI = bulb turns ON at brightness 1.** Firmware bug (Koenkk/zigbee2mqtt#22030, multiple bulb models including E27 WS globe / LED2103G5 / LED2005R5). HA's ZHA sends `Move to Level with On/Off (target=0)` for `turn_off+transition`; on an already-off TRADFRI this gets misinterpreted. Triggered by: (a) duplicate `turn_off` calls during a hold, (b) any `turn_off transition=X` to a bulb that's already off.
- **HA does not see the bulb come back on** — the lamp doesn't proactively report state after this firmware path. `homeassistant.update_entity` forces a poll and reveals the true state.
- **Workaround**: omit `transition:` from any `light.turn_off` action that may target a TRADFRI bulb. The plain ZCL `Off` command (cluster 6 cmd 0) is unaffected. Z2M's equivalent is the device-level `noOffTransition: true` flag, which ZHA does not have.

### Label Registry

- Labels are tagging metadata for entities/devices/areas. Useful for templates: `label_entities('mood')`, `label_entities('illumination') | select('in', area_entities('bedroom'))`.
- **`config/label_registry/create` accepts `name` (required), plus optional `color`/`icon`/`description`. Do NOT pass `label_id`** — it's auto-slugified from `name`.
- **Scenes do not accept `label_id` or `area_id`** as targets. Scene `entities:` must be a literal map of `entity_id` → state. To get label-driven dynamism, use a script with `target: { label_id: ... }` instead of a scene (`scene.turn_on` doesn't accept label targets).

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

## Labels

Light fixtures are tagged by purpose:

| Label | Meaning | Example members |
|-------|---------|-----------------|
| `illumination` | Functional task lighting | `light.ceiling_light`, `light.ikea_of_sweden_jetstrom_40100_light` |
| `mood` | Tunable ambient lighting | `light.anglepoise_light`, `light.ikea_lamp_light` |
| `novelty` | Decorative on/off-only fixtures | lava lamps |

## Custom Frontend

- **HACS** installed at `custom_components/hacs/`
- **auto-entities** card at `www/community/auto-entities.js`, registered in `lovelace_resources`
