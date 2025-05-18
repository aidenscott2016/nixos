{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  publicKey = config.aiden.modules.common.publicKey;
in
{
  imports = [ inputs.nixos-images.nixosModules.image-installer ];
  config = {
    system.stateVersion = "24.11";
    aiden.modules = {
      locale.enable = true;
      avahi.enable = true;
      common = {
        enable = true;
      };
      cli-base.enable = true;
    };
    services.libinput.enable = lib.mkForce false;

    users.users.nixos.openssh.authorizedKeys.keys = [ publicKey ];
    users.users.root.openssh.authorizedKeys.keys = [ publicKey ];

    nixpkgs.overlays = [
      (final: prev: {
        nixos-facter = inputs.nixos-facter.packages.x86_64-linux.nixos-facter;
      })
    ];
  };
}
