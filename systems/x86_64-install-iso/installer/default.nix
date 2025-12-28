{ inputs, ... }:
{
  flake.nixosConfigurations.installer = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Modules
      ../../../modules/nixos/locale/default.nix
      ../../../modules/nixos/avahi/default.nix
      ../../../modules/nixos/common/default.nix
      ../../../modules/nixos/cli-base/default.nix

      # Host-specific config
      ({ config, pkgs, lib, inputs, ... }:
      let
        publicKey = config.narrowdivergent.modules.common.publicKey;
      in
      {
        imports = [ inputs.nixos-images.nixosModules.image-installer ];

        system.stateVersion = lib.mkForce "24.11";
        services.libinput.enable = lib.mkForce false;

        users.users.nixos.openssh.authorizedKeys.keys = [ publicKey ];
        users.users.root.openssh.authorizedKeys.keys = [ publicKey ];

        nixpkgs.overlays = [
          (final: prev: {
            nixos-facter = inputs.nixos-facter.packages.x86_64-linux.nixos-facter;
            # Fix for renamed ZFS package
            zfsUnstable = prev.zfs_unstable;
          })
        ];
      })
    ];
  };
}
