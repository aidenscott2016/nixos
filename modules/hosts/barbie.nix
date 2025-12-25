{ aiden, inputs, ... }:
{
  # Register barbie host
  den.hosts.x86_64-linux.barbie.users.aiden = { };

  # Define barbie host aspect
  den.aspects.barbie = {
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
          ../../systems/x86_64-linux/barbie/disk-configuration.nix
          ../../systems/x86_64-linux/barbie/hardware-configuration.nix
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "barbie.local";
          email = "aiden@barbie.local";
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Networking
        networking.hostName = "barbie";
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
