{ config, inputs, lib, pkgs, systems, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
    ./samba.nix
  ];

  config = {
    services.openssh.enable = true;
    services.openssh.openFirewall = true;
    security.sudo.wheelNeedsPassword = false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    system.stateVersion = "23.11";
    services.bazarr = { enable = true; };
    services.sonarr = { enable = true; };
    networking.firewall.allowedTCPPorts = [ 443 ];
    services.sabnzbd = { enable = true; # configFile = config.age.secrets.sabnzbd.path;
                       };
    users.users.sabnzbd.extraGroups = [ "video" ];
    users.users.sonarr.extraGroups = [ "video" "sabnzbd" ];
    users.users.bazarr.extraGroups = [ "video" "sabnzbd" ];
    aiden.modules = {
      reverseProxy = {
        enabled = true;
        apps = [
          { name = "bazarr"; port = 6767; }
          { name = "sonarr"; port = 8989; }
          { name = "sab"; port = 8080; }
          { name = "jellyfin"; port = 8096; }
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
    };

    environment.systemPackages = with pkgs; [ get_iplayer ];
  };
}
