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
        system.stateVersion = "24.11";

        services.libinput.enable = lib.mkForce false;

        users.users.nixos.openssh.authorizedKeys.keys = [ config.aiden.modules.common.publicKey ];
        users.users.root.openssh.authorizedKeys.keys = [ config.aiden.modules.common.publicKey ];

        nixpkgs.overlays = [
          (final: prev: {
            nixos-facter = inputs.nixos-facter.packages.x86_64-linux.nixos-facter;
          })
        ];
      })
    ];
  };
}
