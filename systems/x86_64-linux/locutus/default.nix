{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports =
    [ ../../../common ./hardware-configuration.nix ./packages.nix ./autorandr ];

  aiden.modules = {
    ios = enabled;
    redshift = enabled;
    printer = enabled;
    ssh = enabled;
    gc = enabled;
    barrier = enabled;
    jellyfin.enabled = false;
    cli-base = enabled;
    desktop = enabled;
    multimedia = enabled;
    emacs = enabled;
    home-assistant = enabled;
  };

  system.stateVersion = "22.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.aiden = { };

  #// why is this?
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  boot = {
    supportedFilesystems = [ "ntfs" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
      };

    };
  };

  networking = {
    hostName = "locutus";
    networkmanager.enable = true;
  };
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
        USB_AUTOSUSPEND = 1;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 85;
        START_CHARGE_THRESH_BAT1 = 50;
        STOP_CHARGE_THRESH_BAT1 = 85;
      };

    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish.domain = true;
    };

    tailscale.enable = true;
    gvfs.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;

}
