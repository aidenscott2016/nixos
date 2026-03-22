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
      config.flake.modules.nixos.restic-b2
      config.flake.modules.nixos.monitoring
      config.flake.modules.nixos.uptime-kuma
      config.flake.modules.nixos.authelia
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
                  hash = "sha256-KB5sutlp6y9e9XJMbLoB2kDNX+rW+CksUO1gvU26eK4=";
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
                { name = "photos"; port = 2283; auth = false; } # native OIDC; mobile app uses OAuth token flow
                { name = "bazarr"; port = 6767; }
                { name = "sonarr"; port = 8989; }
                { name = "sab"; port = 8080; }
                { name = "jellyfin"; port = 8096; auth = false; } # API clients use Jellyfin auth; forward-auth breaks websockets
                { name = "portainer"; port = 9000; auth = false; } # native OIDC; Edge agent uses API tokens
                { name = "deluge"; port = 8112; }
                { name = "radarr"; port = 7878; }
                { name = "slskd"; port = 5030; }
              ];
            };
          };

          age.secrets.opencode-env.file = "${inputs.secrets}/opencode-env.age";
          age.secrets.slskd.file = "${inputs.secrets}/slskd";

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
