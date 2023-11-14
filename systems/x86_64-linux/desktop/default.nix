{ config, pkgs, lib, ... }:
with lib.aiden; {
  imports = [ ./hardware-configuration.nix ];

  aiden.modules = {
    common = enabled;
    ssh = enabled;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-label/870-evo";
      preLVM = true;
    };
  };
  networking.hostName = "desktop";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = { useXkbConfig = true; };

  services.xserver = {
    layout = "gb";
    xkbOptions = "caps:swapescape";
    libinput.enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [ git udiskie ];

  system.stateVersion = "23.05";
  services.udisks2.enable = true;

}

