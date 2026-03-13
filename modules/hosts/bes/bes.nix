{ inputs, config, ... }:
{
  flake.nixosConfigurations.bes = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_hardware-configuration.nix
      ./_disk-config.nix
      ./_portainer.nix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
    ]
    ++ (with config.flake.modules.nixos; [
      common
      architecture
      locale
      avahi
      syncthing
      navidrome
      jellyfin
      paperless
      media-storage
      beets
      opencode
    ])
    ++ [
      config.flake.modules.nixos.immich
    ]
    ++ [
      config.flake.modules.nixos."cli-base"
      config.flake.modules.nixos."reverse-proxy"
    ]
    ++ [
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          networking.hostName = "bes";
          system.stateVersion = "23.11";
          nixpkgs.overlays = [
            inputs.self.overlays.default
            # Pentium J5005 (Gemini Lake) lacks AVX2; use bun baseline binary
            (final: prev: {
              bun = prev.bun.overrideAttrs (old: {
                src = prev.fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
                  hash = "sha256-EE1NA39LNeECFcBQfhd5aR85xXvZHd7v4RyteB4/xLk=";
                };
                sourceRoot = "bun-linux-x64-baseline";
              });
            })
          ];

          aiden = {
            architecture = {
              cpu = "intel";
              gpu = "intel";
            };
            modules = {
              common.domainName = "bes.sw1a1aa.uk";
              reverseProxy.apps = [
                { name = "photos"; port = 2283; }
                { name = "bazarr"; port = 6767; }
                { name = "sonarr"; port = 8989; }
                { name = "sab"; port = 8080; }
                { name = "jellyfin"; port = 8096; }
                { name = "portainer"; port = 9000; }
                { name = "deluge"; port = 8112; }
                { name = "radarr"; port = 7878; }
                { name = "slskd"; port = 5030; }
              ];
            };
          };

          age.secrets.opencode-env.file = "${inputs.self.outPath}/secrets/opencode-env.age";
          age.secrets.slskd.file = "${inputs.self.outPath}/secrets/slskd";
          age.secrets.restic-b2-env.file = "${inputs.self.outPath}/secrets/restic-b2-env.age";
          age.secrets.restic-b2-env.owner = "restic";
          age.secrets.restic-b2-password.file = "${inputs.self.outPath}/secrets/restic-b2-password.age";
          age.secrets.restic-b2-password.owner = "restic";

          users.users.restic = {
            isSystemUser = true;
            group = "restic";
            # immich group gives read access to /media/t7/photos (immich-owned files)
            extraGroups = [ "immich" ];
          };
          users.groups.restic = {};

          services.restic.backups.b2 = {
            user = "restic";
            paths = [
              "/media/t7/photos"
              "/srv/media/Music/library/Cocteau Twins/1993 - Four-Calendar Café"
            ];
            repository = "s3:s3.eu-central-003.backblazeb2.com/backup-uwdcrk";
            environmentFile = config.age.secrets.restic-b2-env.path;
            passwordFile = config.age.secrets.restic-b2-password.path;
            initialize = true;
            createWrapper = true;
            timerConfig = {
              OnCalendar = "daily";
              Persistent = "true";
            };
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 6"
              "--keep-yearly 2"
            ];
          };

          # UID-based bandwidth shaping for restic via tc HTB + iptables fwmark.
          # Daytime (0700-2200): 5 Mbit/s upload cap. Nighttime: effectively unlimited.
          systemd.services.restic-tc-setup = {
            description = "tc bandwidth shaping for restic (UID-based)";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            path = with pkgs; [ iproute2 iptables ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "restic-tc-setup" ''
                IFACE=$(ip route show default | awk '/default/ {print $5; exit}')

                # HTB root qdisc — default traffic → class 1:10 (unlimited)
                tc qdisc add dev "$IFACE" root handle 1: htb default 10

                # Bandwidth classes
                tc class add dev "$IFACE" parent 1:  classid 1:1  htb rate 1gbit ceil 1gbit
                tc class add dev "$IFACE" parent 1:1 classid 1:10 htb rate 1gbit ceil 1gbit
                # Restic class — starts unlimited; restic-tc-day.timer throttles it at 07:00
                tc class add dev "$IFACE" parent 1:1 classid 1:20 htb rate 1gbit ceil 1gbit

                # Steer fwmark 0x1 → class 1:20 (restic)
                tc filter add dev "$IFACE" parent 1: protocol ip handle 1 fw classid 1:20

                # Mark outgoing packets from restic UID
                iptables -t mangle -A OUTPUT -m owner --uid-owner restic -j MARK --set-mark 1
              '';
              ExecStop = pkgs.writeShellScript "restic-tc-teardown" ''
                IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
                iptables -t mangle -D OUTPUT -m owner --uid-owner restic -j MARK --set-mark 1 || true
                tc qdisc del dev "$IFACE" root || true
              '';
            };
          };

          systemd.services.restic-tc-day = {
            description = "Throttle restic to 5 Mbit (daytime 0700-2200)";
            after = [ "restic-tc-setup.service" ];
            requires = [ "restic-tc-setup.service" ];
            path = [ pkgs.iproute2 ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeShellScript "restic-tc-day" ''
                IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
                tc class change dev "$IFACE" parent 1:1 classid 1:20 htb rate 5mbit ceil 5mbit
              '';
            };
          };

          systemd.timers.restic-tc-day = {
            description = "Throttle restic at 07:00";
            wantedBy = [ "timers.target" ];
            timerConfig = { OnCalendar = "*-*-* 07:00:00"; Persistent = true; };
          };

          systemd.services.restic-tc-night = {
            description = "Unthrottle restic (nighttime 2200-0700)";
            after = [ "restic-tc-setup.service" ];
            requires = [ "restic-tc-setup.service" ];
            path = [ pkgs.iproute2 ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = pkgs.writeShellScript "restic-tc-night" ''
                IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
                tc class change dev "$IFACE" parent 1:1 classid 1:20 htb rate 1gbit ceil 1gbit
              '';
            };
          };

          systemd.timers.restic-tc-night = {
            description = "Unthrottle restic at 22:00";
            wantedBy = [ "timers.target" ];
            timerConfig = { OnCalendar = "*-*-* 22:00:00"; Persistent = true; };
          };

          programs.mosh.enable = true;

          services.iperf3.enable = true;
          services.iperf3.openFirewall = true;
          services.openssh.enable = true;
          services.openssh.openFirewall = true;
          security.sudo.wheelNeedsPassword = false;
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          services.cockpit.enable = true;
          services.cockpit.openFirewall = true;

          services.slskd = {
            enable = true;
            domain = null;
            settings = {
              shares.directories = [ "/srv/media/Music" ];
              directories = {
                incomplete = "/srv/media/Music/download/incomplete";
                downloads = "/srv/media/Music/download/complete";
              };
            };
            environmentFile = config.age.secrets.slskd.path;
          };

          services.deluge = {
            enable = true;
            web = {
              enable = true;
              port = 8112;
            };
          };

          services.bazarr.enable = true;
          services.sonarr.enable = true;
          services.radarr.enable = true;
          services.sabnzbd.enable = true;

          users.groups.media.members = [
            "slskd"
            "deluge"
            "bazarr"
            "sonarr"
            "radarr"
            "sabnzbd"
            "navidrome"
            "jellyfin"
          ];

          users.users.aiden.extraGroups = [
            "sadnzbd"
            "deluge"
          ];

          networking.firewall.allowedTCPPorts = [ 443 5000 ];

          environment.systemPackages = with pkgs; [
            get_iplayer
            wol
            iperf3
          ];
        }
      )
    ];
  };
}
