{ config, inputs, lib, pkgs, systems, ... }:
{
  imports = [ ./hardware-configuration.nix ./disk-config.nix inputs.disko.nixosModules.default ];

  config = {
    # make it a module
    services.openssh.enable = true;
    services.openssh.openFirewall = true;
    security.sudo.wheelNeedsPassword = false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    system.stateVersion = "23.11";
    aiden.modules = {
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
  };
}
