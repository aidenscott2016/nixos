{ config, pkgs, nixos-hardware, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common/base.nix nixos-hardware.nixosModules ];

  networking.hostName = "chris";
  services = {
    xserver =
      {
        desktopManager.plasma5.enable = true;
      };
  };
}
