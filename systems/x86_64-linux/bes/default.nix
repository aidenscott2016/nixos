{ config, inputs, lib, pkgs, systems, ... }:

 {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
    ./portainer.nix
  ];

  config =

    {
      services.openssh.enable = true;
      services.openssh.openFirewall = true;
      security.sudo.wheelNeedsPassword = false;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      system.stateVersion = "23.11";

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
        enable = true; # configFile = config.age.secrets.sabnzbd.path;
        group = "video";
      };
      users.users.sabnzbd.extraGroups = [ "video" ];

      users.users.aiden.extraGroups = [ "video" "sadnzbd" "deluge" ];

      networking.firewall.allowedTCPPorts = [ 443 5000 ];

      aiden.modules = {
        powermanagement.enabled  = true;
        gc.enabled = false;
        cli-base.enabled = true;
        locale.enabled = true;
        reverseProxy = {
          enabled = true;
          apps = [
            {
              name = "bazarr";
              port = 6767;
            }
            {
              name = "sonarr";
              port = 8989;
            }
            {
              name = "sab";
              port = 8080;
            }
            {
              name = "jellyfin";
              port = 8096;
            }
            {
              name = "portainer";
              port = 9000;
            }
            {
              name = "deluge";
              port = 8112;
            }
            {
              name = "radarr";
              port = 7878;
            }
          ];
        };
        avahi.enabled = true;
        jellyfin = {
          enabled = true;
          hwAccel = {
            enabled = true;
            arch = "intel";
          };
        };
        common = {
          domainName = "bes.sw1a1aa.uk";
          enabled = true;
        };
        samba = {
          enabled = true;
          shares.t7 = {
            path = "/media/t7";
            writable = "true";
          };
        };
      };
      environment.systemPackages = with pkgs; [
        get_iplayer
        wol
        iperf3

        (beets-unstable.override {
          pluginOverrides = {
            #fetchart
            #badfiles.enable = true;
            discogs.enable = true;
            copyartifacts = {
              enable = true;
              propagatedBuildInputs = [ beetsPackages.copyartifacts ];
            };
          };
        })

      ];

    };
}
