{ den, nd, inputs, ... }: {
  # Host declaration (no persistent users for installer ISO)
  den.hosts.x86_64-linux.installer.mainModule = {};

  # Host aspect
  den.aspects.installer = {
    includes = [
      nd.common
      nd.locale
      nd.avahi
      nd.cli-base
    ];

    nixos = { config, pkgs, lib, ... }:
    let
      publicKey = config.narrowdivergent.aspects.common.publicKey;
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
    };
  };
}
