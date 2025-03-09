{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports = [
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.disko.nixosModules.default
    ./disk-configuration.nix
  ];

  facter.reportPath = ./facter.json;
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
    initrd.kernelModules = [ "nvidia" ];
    #extraModulePackages = [ pkgs.linuxPackages.nvidia_x11 ];
  };

  programs = {
    nm-applet.enable = true;
    nix-ld.enable = true;
    nh.enable = true;
    virt-manager.enable = true;
  };

  services = {
    physlock = {
      muteKernelMessages = true;
      enable = true;
      lockOn.suspend = true;
    };
    libinput.enable = true;
    fstrim.enable = true;
    xserver = {
      videoDrivers = [ "nvidia" ];
      enable = true;
    };
    tailscale.enable = true;
    gvfs.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    nvidia = {
      prime = {
        # Make sure to use the correct Bus ID values for your system!
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
        #
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  networking = { networkmanager.enable = true; };
  services.envfs.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa vpl-gpu-rt libva ];
  };

  #services.gnome.gnome-keyring.enable = true;
  services.mullvad-vpn.enable = true;

  services.blueman.enable = true;

  # yubikey support
  services.pcscd.enable = true;
  security.polkit.enable = true;

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

    vmVariant = {
      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = true;
      virtualisation = {
        memorySize = 2048;
        cores = 3;
      };
    };
  };

  services.emacs = {
    enable = true;
    package =
      pkgs.emacs; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };

  # darkman needs this
  environment.pathsToLink =
    [ "/share/xdg-desktop-portal" "/share/applications" ];
  programs.steam.gamescopeSession.enable = true;
  services.geoclue2 = {
    enable = true;
    enableWifi = false;
    appConfig.darkman = {
      isAllowed = true;
      isSystem = true;
    };
  };
}
