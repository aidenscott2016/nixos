{ den, inputs, config, lib, pkgs, ... }:
{
  # Define the test host aspect - name must match hostname for auto-linking
  den.aspects.test = {
    includes = with den.aspects; [
      architecture
      locale
      gc
      cli-base
      nix
      ssh
      common
    ];

    nixos = {
      # Set architecture options
      aiden.architecture = {
        cpu = "intel";
        gpu = "intel";
      };

      # Set common options
      aiden.aspects.common = {
        domainName = "test.local";
        email = "test@example.com";
      };

      # Minimal hardware configuration for testing
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use a generic kernel
      boot.kernelPackages = pkgs.linuxPackages;

      # Minimal filesystem
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

      # Networking
      networking.hostName = "test";
      networking.useDHCP = lib.mkDefault true;

      # System state version
      system.stateVersion = "25.11";
    };
  };
}
