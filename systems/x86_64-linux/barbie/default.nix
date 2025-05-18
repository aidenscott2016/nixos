# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    ./disk-configuration.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.gpd-pocket-3
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "barbie";
  networking.networkmanager.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  aiden.modules = {
    common.enable = true;
    ssh.enable = true;
    locale.enable = true;
  };
  services.openssh.openFirewall = true;
  services.desktopManager.plasma6.enable = true;

  security.sudo.wheelNeedsPassword = false; # desktop archetype

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.aiden = { };
  system.stateVersion = "24.05"; # Did you read the comment?
  environment.systemPackages = [
    pkgs.maliit-keyboard
  ];
}
