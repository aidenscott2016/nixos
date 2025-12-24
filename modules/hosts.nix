{ aiden, inputs, ... }:
{
  # Register den hosts
  den.hosts.x86_64-linux.test.users.aiden = { };
  den.hosts.x86_64-linux.barbie-den.users.aiden = { };

  # Define host-specific aspects
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

  den.aspects.barbie-den = {
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
      { pkgs, lib, config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.default
          inputs.nixos-hardware.nixosModules.gpd-pocket-3
          inputs.home-manager.nixosModules.home-manager
          ../systems/x86_64-linux/barbie-den/disk-configuration.nix
          ../systems/x86_64-linux/barbie-den/hardware-configuration.nix
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "barbie-den.local";
          email = "aiden@barbie-den.local";
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Networking
        networking.hostName = "barbie-den";
        networking.networkmanager.enable = true;

        # X11 and desktop
        services.xserver.enable = true;
        services.desktopManager.plasma6.enable = true;

        # Audio
        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };

        # SSH
        services.openssh.openFirewall = true;

        # Security
        security.sudo.wheelNeedsPassword = false;

        # Home manager
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.aiden = {
          home.stateVersion = "24.05";
        };

        # Packages
        environment.systemPackages = [
          pkgs.maliit-keyboard
        ];

        system.stateVersion = "24.05";
      };
  };
}
