{ aiden, inputs, ... }:
{
  # Register bes-den host
  den.hosts.x86_64-linux.bes-den.users.aiden = { };

  # Define bes-den host aspect
  den.aspects.bes-den = {
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
    ];

    nixos =
      { pkgs, lib, config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.default
          inputs.agenix.nixosModules.default
          ../../systems/x86_64-linux/bes-den/disk-config.nix
          ../../systems/x86_64-linux/bes-den/hardware-configuration.nix
          ../../systems/x86_64-linux/bes-den/portainer.nix
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "amd";
          gpu = "amd";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "bes.sw1a1aa.uk";
          email = "aiden@bes.sw1a1aa.uk";
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Networking
        networking.hostName = "bes-den";

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
        };
        users.users.sabnzbd.extraGroups = [ "video" ];

        services.jellyfin = {
          enable = true;
          group = "video";
        };
        users.users.jellyfin.extraGroups = [ "video" ];

        services.navidrome = {
          enable = true;
          settings = {
            MusicFolder = "/media/t7/Music";
          };
        };

        services.paperless = {
          enable = true;
          address = "0.0.0.0";
          port = 28981;
        };

        # Nginx reverse proxy for services
        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          virtualHosts = {
            "bazarr.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:6767";
            };
            "sonarr.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:8989";
            };
            "sab.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:8080";
            };
            "jellyfin.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:8096";
            };
            "portainer.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:9000";
            };
            "deluge.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:8112";
            };
            "radarr.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:7878";
            };
            "slskd.bes.sw1a1aa.uk" = {
              locations."/".proxyPass = "http://127.0.0.1:5030";
            };
          };
        };

        networking.firewall.allowedTCPPorts = [ 80 443 ];

        system.stateVersion = "23.11";
      };
  };
}
