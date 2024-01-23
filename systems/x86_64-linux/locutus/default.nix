{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
  ];

  environment.systemPackages = with pkgs;
    [ inputs.disko.packages.x86_64-linux.disko ];
  aiden.modules = {
    avahi = enabled;
    common = enabled;
    ios = enabled;
    redshift = enabled;
    printer = enabled;
    ssh = enabled;
    gc = enabled;
    cli-base = enabled;
    desktop = enabled;
    multimedia = enabled;
    emacs = enabled;
    jellyfin.enabled = false;
  };

  system.stateVersion = "22.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.aiden = {
    home.stateVersion = "22.05";
  };

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

  networking = {
    hostName = "locutus";
    networkmanager.enable = true;
  };

  #programs.bash.undistract.me
}
