{ config, pkgs, lib, modulesPath, ... }:
let
  publicKey = config.aiden.modules.common.publicKey;
in
{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];
  config = {
    users.users.root.initialPassword = "password";
    system.stateVersion = "23.11";
    aiden.modules = {
      avahi.enabled = true;
      common = {
        enabled = true;
      };
    };
    services.xserver.libinput.enable = lib.mkForce false;

    users.users.nixos.openssh.authorizedKeys.keys = [publicKey];
    users.users.root.openssh.authorizedKeys.keys = [publicKey];
  };
}
