{ config, pkgs, lib, myModulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    "${myModulesPath}/ios.nix"
    "${myModulesPath}/redshift.nix"
    "${myModulesPath}/printer.nix"
    "${myModulesPath}/ssh.nix"
    "${myModulesPath}/gc.nix"
    "${myModulesPath}/barrier.nix"
    "${myModulesPath}/transmission.nix"
    "${myModulesPath}/jellyfin.nix"
    "${myModulesPath}/cli-base.nix"
    #"${myModulesPath}/desktop.nix"
    "${myModulesPath}/nixos.nix"
    "${myModulesPath}/multimedia.nix"
    "${myModulesPath}/emacs.nix"
    "${myModulesPath}/steam.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

  networking.hostName = "locutus";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  services = {
    fstrim.enable = true;
    upower.enable = true;
    auto-cpufreq.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    xserver.enable = true;
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 0;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 85;
        START_CHARGE_THRESH_BAT1 = 50;
        STOP_CHARGE_THRESH_BAT1 = 85;
      };

    };
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;

  services.gvfs.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];

  # services.xserver.dpi = 180;
}

