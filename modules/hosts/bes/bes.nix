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
    ])
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
          nixpkgs.overlays = [ inputs.self.overlays.default ];

          aiden = {
            architecture = {
              cpu = "intel";
              gpu = "intel";
            };
            modules = {
              common.domainName = "bes.sw1a1aa.uk";
              reverseProxy.apps = [
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

          age.secrets.slskd.file = "${inputs.self.outPath}/secrets/slskd";
          age.secrets.restic-b2-env.file = "${inputs.self.outPath}/secrets/restic-b2-env.age";
          age.secrets.restic-b2-password.file = "${inputs.self.outPath}/secrets/restic-b2-password.age";

          services.restic.backups.b2 = {
            paths = [ "/srv/media/Music/library/Cocteau Twins/1993 - Four-Calendar Café" ];
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
            opencode
          ];
        }
      )
    ];
  };
}
