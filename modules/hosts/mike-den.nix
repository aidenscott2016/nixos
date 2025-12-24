{ aiden, inputs, ... }:
{
  # Register mike-den host
  den.hosts.x86_64-linux.mike-den.users.aiden = { };

  # Define mike-den host aspect
  den.aspects.mike-den = {
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
      aiden.oblivion-sync
      aiden.virtualisation
      aiden.home-manager
      aiden.nvidia
      aiden.scanner
    ];

    nixos =
      { pkgs, lib, config, ... }:
      {
        imports = [
          ./systems/x86_64-linux/mike/disk-configuration.nix
          ./systems/x86_64-linux/mike/autorandr
          inputs.dwm.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.default
        ];

        facter.reportPath = ./systems/x86_64-linux/mike/facter.json;

        # Set architecture options
        aiden.aspects.architecture = {
          cpu = "intel";
          gpu = "nvidia";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "mike.sw1a1aa.uk";
          email = "aiden@mike.sw1a1aa.uk";
        };

        # Set gaming options
        aiden.aspects.gaming = {
          steam.enable = true;
          moonlight.client.enable = true;
          oblivionSync.enable = true;
        };

        # Set NVIDIA options
        aiden.aspects.nvidia = {
          prime = {
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        # Boot
        boot.initrd.systemd.enable = true;
        boot.loader.systemd-boot.enable = true;
        boot = {
          kernelParams = [ "resume_offset=264448" ];
          resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";
        };

        # Power management
        services.upower.enable = true;

        system.stateVersion = "22.05";
      };
  };
}
