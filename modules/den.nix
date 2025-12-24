{ aiden, ... }:
{
  # Register den hosts
  den.hosts.x86_64-linux.test.users.aiden = { };

  # Define aspects for hosts (name must match hostname)
  den.aspects.test = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
    ];

    nixos =
      { pkgs, lib, ... }:
      {
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
        boot.kernelPackages = pkgs.linuxPackages;

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-label/boot";
          fsType = "vfat";
        };

        networking.hostName = "test";
        networking.useDHCP = lib.mkDefault true;

        system.stateVersion = "25.11";
      };
  };
}
