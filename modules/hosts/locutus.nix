{ aiden, inputs, ... }:
{
  # Register locutus host
  den.hosts.x86_64-linux.locutus.users.aiden = { };

  # Define locutus host aspect
  den.aspects.locutus = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.desktop
      aiden.gaming
      aiden.steam
      aiden.virtualisation
      aiden.home-manager
    ];

    nixos =
      { pkgs, lib, config, ... }:
      {
        imports = [
          ../../systems/x86_64-linux/locutus/hardware-configuration.nix
          ../../systems/x86_64-linux/locutus/autorandr
          inputs.dwm.nixosModules.default
          inputs.agenix.nixosModules.default
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "amd";
          gpu = "amd";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "locutus.sw1a1aa.uk";
          email = "aiden@locutus.sw1a1aa.uk";
        };

        # Set gaming options
        aiden.aspects.gaming = {
          steam.enable = true;
          moonlight.client.enable = true;
        };

        # Boot configuration
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

        system.stateVersion = "22.05";
      };
  };
}
