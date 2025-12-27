{ aiden, inputs, ... }:
{
  # Register mike host
  den.hosts.x86_64-linux.mike.users.aiden = { };

  # Define mike host aspect
  den.aspects.mike = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
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
          ../../systems/x86_64-linux/mike/disk-configuration.nix
          ../../systems/x86_64-linux/mike/autorandr
          inputs.dwm.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.default
        ];

        facter.reportPath = ../../systems/x86_64-linux/mike/facter.json;

        # Set architecture options
        aiden.architecture = {
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

        # Hostname (must be set explicitly - den doesn't derive from filename like Snowfall)
        networking.hostName = "mike";

        # Boot
        boot.initrd.systemd.enable = true;
        boot.loader.systemd-boot.enable = true;
        boot = {
          kernelParams = [ "resume_offset=264448" ];
          resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";
        };

        # Power management
        services.upower.enable = true;

        # Packages
        environment.systemPackages = with pkgs; [
          naps2
          antigravity-fhs
        ];

        system.stateVersion = "22.05";
      };
  };
}
