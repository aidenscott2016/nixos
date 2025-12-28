{ den, nd, inputs, ... }: {
  # Host declaration with user
  den.hosts.x86_64-linux.mike.users.aiden = {};

  # Host aspect
  den.aspects.mike = {
    includes = [
      nd.common
      nd.locale
      nd.avahi
      nd.ssh
      nd.cli-base
      nd.nix
      nd.architecture
      nd.desktop
      nd.gaming
      nd.nvidia
      nd.scanner
      nd.virtualisation
      den.provides.home-manager
    ];

    nixos = { config, pkgs, lib, ... }: {
      imports = [
        ./_packages.nix
        ./autorandr
        inputs.dwm.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.disko.nixosModules.default
        ./_disk-configuration.nix
      ];

      nixpkgs.config.allowUnfree = true;

      facter.reportPath = ./facter.json;

      boot.initrd.systemd.enable = true;
      boot.loader.systemd-boot.enable = true;
      boot.kernelParams = [ "resume_offset=264448" ];
      boot.resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";

      services.upower.enable = true;

      system.stateVersion = "22.05";

      narrowdivergent = {
        architecture = {
          cpu = "intel";
          gpu = "nvidia";
        };
        programs.beets.enable = lib.mkForce false;
        aspects = {
          gaming = {
            steam.enable = true;
            games.oblivionSync.enable = true;
            moonlight.client.enable = true;
          };
          nvidia = {
            prime = {
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
            };
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
        };
      };
    };

    homeManager = {
      imports = [
        nd.home.bash
        nd.home.darkman
        nd.home.desktop
        nd.home.easyeffects
        nd.home.firefox
        nd.home.git
        nd.home.gpg-agent
        nd.home.ideavim
        nd.home.ssh
        nd.home.tmux
        nd.home.vim
        nd.home.xdg-portal
      ];
    };
  };
}
