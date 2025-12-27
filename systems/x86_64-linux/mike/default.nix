{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib.extend (final: prev: {
    aiden = import ../../../lib/aiden { lib = final; };
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
      ../../../modules/nixos/home-manager/default.nix
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

        facter.reportPath = ./facter.json;

        boot.initrd.systemd.enable = true;
        services.upower.enable = true;

        aiden = {
          architecture = {
            cpu = "intel";
            gpu = "nvidia";
          };
          programs.beets.enable = lib.mkForce false;
          modules = {
            gaming = {
              games.oblivionSync.enable = true;
              steam.enable = true;
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
