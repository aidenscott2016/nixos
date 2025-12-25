{ aiden, ... }:
{
  # Register pxe host
  den.hosts.x86_64-linux.pxe.users = {
    nixos = { };
    root = { };
  };

  # Define pxe host aspect
  den.aspects.pxe = {
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
      { pkgs, lib, config, modulesPath, ... }:
      let
        publicKey = config.aiden.aspects.common.publicKey;
      in
      {
        imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];

        # Hostname
        networking.hostName = "pxe";

        # Set common options
        aiden.aspects.common = {
          domainName = "pxe.sw1a1aa.uk";
          email = "aiden@pxe.sw1a1aa.uk";
        };

        # Disable libinput for netboot
        services.libinput.enable = lib.mkForce false;

        # SSH keys for netboot users
        users.users.nixos.openssh.authorizedKeys.keys = [ publicKey ];
        users.users.root.openssh.authorizedKeys.keys = [ publicKey ];

        # Netboot packages
        environment.systemPackages = with pkgs; [
          rsync
          tmux
          nixos-facter
        ];

        # Squashfs compression
        netboot.squashfsCompression = "zstd -Xcompression-level 1";

        system.stateVersion = "23.11";
      };
  };
}
