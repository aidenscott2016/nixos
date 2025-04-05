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
      steam.enabled = true;
      thunar = enabled;
      locale = enabled;
      keyd = enabled;
      powermanagement = enabled;
      darkman = enabled;
      gaming = {
        steam.enabled = true;
        moonlight.client.enabled = true;
      };
    };
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

  programs = {

    # desktop
    nm-applet.enable = true;

    # desktop
    nh.enable = true;

    # virt
    virt-manager.enable = true;
  };

  services = {
    # desktop
    physlock = {
      muteKernelMessages = true;
      enable = true;
      lockOn.suspend = true;
    };
    libinput.enable = true;

    # hardware
    fstrim.enable = true;

    # desktop
    xserver = {
      videoDrivers = [ "amdgpu" ];
      enable = true;
    };

    # neworking
    tailscale.enable = true;
    gvfs.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    #bluetooth
    bluetooth.enable = true;
  };

  # desktop
  security.sudo.wheelNeedsPassword = false;

  # hardware
  networking = { networkmanager.enable = true; };

  services.envfs.enable = true;

  # dekstop
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa amdvlk libva ];
  };

  #services.gnome.gnome-keyring.enable = true;

  # networking
  services.mullvad-vpn.enable = true;

  # bluetooth
  services.blueman.enable = true;

  # virtuvirtualisation
  users.groups.libvirtd.members = [ "aiden" ];
  virtualisation = {
    podman = {
      enable = false;
      dockerSocket.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;

    };
    docker = {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      enable = true;
    };

    libvirtd.enable = true;

    spiceUSBRedirection.enable = true;

    # vm gues
    vmVariant = {
      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = true;
      virtualisation = {
        memorySize = 2048;
        cores = 3;
      };
    };
  };

  # dekstop
  # geoclue
  services.geoclue2 = {
    enable = true;
    enableWifi = false;
    appConfig.darkman = {
      isAllowed = true;
      isSystem = true;
    };
  };

  # flatpak
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  services.flatpak.enable = true;

  # dekstop
  # pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  #desktop
  #easy effects
  programs.dconf.enable = true;
}
