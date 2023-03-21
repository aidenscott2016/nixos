{ config, pkgs, lib, myModulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    ./disko.nix
    #./samba.nix
    ./music.nix
    "${myModulesPath}/ios.nix"
    "${myModulesPath}/redshift.nix"
    "${myModulesPath}/printer.nix"
    "${myModulesPath}/ssh.nix"
    "${myModulesPath}/php-docker.nix"
    "${myModulesPath}/gc.nix"
    "${myModulesPath}/barrier.nix"
    "${myModulesPath}/transmission.nix"
    "${myModulesPath}/jellyfin.nix"
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
    xserver.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };




  services.gvfs.enable = true;

  # move this to dwm some time
  services.picom = {
    enable = true;
    vSync = true;
  };

  programs.light.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];

  # services.xserver.dpi = 180;
}

