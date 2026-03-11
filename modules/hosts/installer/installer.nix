{ inputs, config, ... }:
{
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-images.nixosModules.image-installer
    ] ++ (with config.flake.modules.nixos; [
      common locale avahi
    ]) ++ [
      config.flake.modules.nixos."cli-base"
    ] ++ [
      ({ config, lib, pkgs, ... }: {
        networking.hostName = "installer";
        services.libinput.enable = lib.mkForce false;

        users.users.nixos.openssh.authorizedKeys.keys = [
          config.aiden.modules.common.publicKey
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFPzeWccRjpB6jb83yXaZ8oaugea4TZ7bXmhMbeop64"
        ];
        users.users.root.openssh.authorizedKeys.keys = [
          config.aiden.modules.common.publicKey
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFPzeWccRjpB6jb83yXaZ8oaugea4TZ7bXmhMbeop64"
        ];

        nixpkgs.overlays = [
          (final: prev: {
            nixos-facter = inputs.nixos-facter.packages.x86_64-linux.nixos-facter;
          })
        ];
      })
    ];
  };
}
