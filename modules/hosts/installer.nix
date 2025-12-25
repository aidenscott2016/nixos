{ aiden, inputs, ... }:
{
  # Register installer host
  den.hosts.x86_64-linux.installer.users = {
    nixos = { };
    root = { };
  };

  # Define installer host aspect
  den.aspects.installer = {
    includes = [
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.avahi
    ];

    nixos =
      { pkgs, lib, config, ... }:
      let
        publicKey = config.aiden.aspects.common.publicKey;
      in
      {
        imports = [ inputs.nixos-images.nixosModules.image-installer ];

        # Hostname
        networking.hostName = "installer";

        # Set common options
        aiden.aspects.common = {
          domainName = "installer.sw1a1aa.uk";
          email = "aiden@installer.sw1a1aa.uk";
        };

        # Disable libinput for installer
        services.libinput.enable = lib.mkForce false;

        # SSH keys for installer users
        users.users.nixos.openssh.authorizedKeys.keys = [ publicKey ];
        users.users.root.openssh.authorizedKeys.keys = [ publicKey ];

        # Nixos-facter overlay
        nixpkgs.overlays = [
          (final: prev: {
            nixos-facter = inputs.nixos-facter.packages.x86_64-linux.nixos-facter;
          })
        ];

        system.stateVersion = "24.11";
      };
  };
}
