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
  ];
  aiden = {
    architecture = {
      cpu = "amd";
      gpu = "amd";
    };
    modules = {
      desktop = enabled;
      gc = enabled;
      virtualisation = enabled;
      gaming = {
        steam.enabled = true;
        moonlight.client.enabled = true;
      };
      home-manager = enabled;
    };
  };

  system.stateVersion = "22.05";

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
    # nix
    nh.enable = true;

    
  };

  services = {
    # hardware
    libinput.enable = true;

    # hardware
    fstrim.enable = true;

    # neworking
    tailscale.enable = true;
    gvfs.enable = true;
  };

  # hardware
  networking = { networkmanager.enable = true; };

  # networking
  services.mullvad-vpn.enable = true;

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
}
