{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (final: prev: {
    narrowdivergent = import ../../../lib/narrowdivergent { lib = final; };
  });
in
{
  flake.nixosConfigurations.mike = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs lib; };
    modules = [
      ../../../modules/nixos/architecture/default.nix
      ../../../modules/nixos/scanner/default.nix
      ../../../modules/nixos/nvidia/default.nix
      ../../../modules/nixos/desktop/default.nix
      ../../../modules/nixos/gaming/default.nix
      ../../../modules/nixos/virtualisation/default.nix
      ../../../modules/nixos/nix/default.nix

      ({ config, pkgs, lib, inputs, ... }: {
        imports = [
          ./packages.nix
          ./autorandr
          inputs.dwm.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.default
          ./disk-configuration.nix
          inputs.home-manager.nixosModules.home-manager
        ];

        nixpkgs.config.allowUnfree = true;

        facter.reportPath = ./facter.json;

        boot.initrd.systemd.enable = true;
        services.upower.enable = true;

        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.aiden = {
          imports = [
            ../../../modules/home/bash/default.nix
            ../../../modules/home/darkman/default.nix
            ../../../modules/home/desktop/default.nix
            ../../../modules/home/easyeffects/default.nix
            ../../../modules/home/firefox/default.nix
            ../../../modules/home/git/default.nix
            ../../../modules/home/gpg-agent/default.nix
            ../../../modules/home/ideavim/default.nix
            ../../../modules/home/ssh/default.nix
            ../../../modules/home/tmux/default.nix
            ../../../modules/home/vim/default.nix
            ../../../modules/home/xdg-portal/default.nix
          ];
        };

        narrowdivergent = {
          architecture = {
            cpu = "intel";
            gpu = "nvidia";
          };
          programs.beets.enable = lib.mkForce false;
          modules = {
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

        system.stateVersion = "22.05";

        boot.loader.systemd-boot.enable = true;
        boot = {
          kernelParams = [
            "resume_offset=264448"
          ];
          resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";
        };
      })
    ];
  };
}
