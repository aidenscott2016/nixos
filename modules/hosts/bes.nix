{ aiden, inputs, ... }:
{
  # Register bes host
  den.hosts.x86_64-linux.bes.users.aiden = { };

  # Define bes host aspect
  den.aspects.bes = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.avahi
      aiden.syncthing
      aiden.powermanagement
      aiden.jellyfin
      aiden.navidrome
      aiden.paperless
      aiden.reverse-proxy
    ];

    nixos =
      { pkgs, lib, config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.default
          inputs.agenix.nixosModules.default
          ../../systems/x86_64-linux/bes/disk-config.nix
          ../../systems/x86_64-linux/bes/hardware-configuration.nix
          ../../systems/x86_64-linux/bes/portainer.nix
        ];

        # Set architecture options (Intel, not AMD!)
        aiden.architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        # Enable the aspects
        aiden.aspects.jellyfin.enable = true;
        aiden.aspects.navidrome.enable = true;
        aiden.aspects.paperless.enable = true;
        aiden.aspects.reverse-proxy = {
          enable = true;
          apps = [
            { name = "bazarr"; port = 6767; }
            { name = "sonarr"; port = 8989; }
            { name = "sab"; port = 8080; }
            { name = "jellyfin"; port = 8096; }
            { name = "portainer"; port = 9000; }
            { name = "deluge"; port = 8112; }
            { name = "radarr"; port = 7878; }
            { name = "slskd"; port = 5030; }
            { name = "navidrome"; port = 4533; }
            { name = "paperless"; port = 28981; }
          ];
        };

        # Add missing packages from old config
        environment.systemPackages = with pkgs; [
          get_iplayer
          wol
          iperf3
        ];

        # Add missing user groups
        users.users.aiden.extraGroups = [ "video" "sabnzbd" "deluge" ];

        # Set common options
        aiden.aspects.common = {
          domainName = "bes.sw1a1aa.uk";
          email = "aiden@bes.sw1a1aa.uk";
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Networking
        networking.hostName = "bes";

        # SSH
        services.openssh.openFirewall = true;

        # Security
        security.sudo.wheelNeedsPassword = false;

        # Services
        services.iperf3 = {
          enable = true;
          openFirewall = true;
        };

        services.cockpit = {
          enable = true;
          openFirewall = true;
        };

        # Media services
        age.secrets.slskd.file = "${inputs.self.outPath}/secrets/slskd";
        services.slskd = {
          enable = true;
          domain = null;
          group = "video";
          settings = {
            shares.directories = [ "/media/t7/Music" ];
            directories = {
              incomplete = "/media/t7/Music/download/incomplete";
              downloads = "/media/t7/Music/download/complete";
            };
          };
          environmentFile = config.age.secrets.slskd.path;
        };
        users.users.slskd.extraGroups = [ "video" ];

        services.deluge = {
          enable = true;
          web = {
            enable = true;
            port = 8112;
          };
        };
        users.users.deluge.extraGroups = [ "video" ];

        services.bazarr = {
          enable = true;
          group = "video";
        };
        users.users.bazarr.extraGroups = [ "video" ];

        services.sonarr = {
          enable = true;
          group = "video";
        };
        users.users.sonarr.extraGroups = [ "video" ];

        services.radarr = {
          enable = true;
          group = "video";
        };
        users.users.radarr.extraGroups = [ "video" ];

        services.sabnzbd = {
          enable = true;
          group = "video";
        };
        users.users.sabnzbd.extraGroups = [ "video" ];

        # jellyfin, navidrome, paperless, and reverse-proxy are now handled by aspects

        networking.firewall.allowedTCPPorts = [ 443 5000 ];

        system.stateVersion = "23.11";
      };
  };
}
