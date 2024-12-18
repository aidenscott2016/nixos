{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    inputs.disko.packages.x86_64-linux.disko
    docker-compose
  ];
  aiden = {
    modules = {
      avahi = enabled;
      common = enabled;
      ios = enabled;
      redshift = enabled;
      printer = enabled;
      ssh = enabled;
      gc = enabled;
      cli-base = enabled;
      multimedia = enabled;
      emacs = enabled;
      steam.enabled = false;
      thunar = enabled;
      locale = enabled;
      keyd = enabled;
      powermanagement = enabled;
    };
    programs = { openttd.enabled = true; };
  };

  system.stateVersion = "22.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.aiden = { };

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
    physlock = {
      enable = true;
      lockOn.suspend = true;
    };
    libinput.enable = true;
    fstrim.enable = true;
    auto-cpufreq.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    xserver = { enable = true; };
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

  virtualisation.podman = {
    enable = false;
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;

  };
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enable = true;
  };
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ mesa amdvlk libva ];
    driSupport = true;
  };

  services.gnome.gnome-keyring.enable = true;
  services.mullvad-vpn.enable = true;

  services.blueman.enable = true;
}
