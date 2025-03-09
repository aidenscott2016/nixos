{ config, pkgs, lib, modulesPath, ... }:
let publicKey = config.aiden.modules.common.publicKey;
in {
  imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];
  config = {
    system.stateVersion = "23.11";
    aiden.modules = {
      locale.enabled = true;
      avahi.enabled = true;
      common = { enabled = true; };
      cli-base.enabled = true;
    };
    services.libinput.enable = lib.mkForce false;

    users.users.nixos.openssh.authorizedKeys.keys = [ publicKey ];
    users.users.root.openssh.authorizedKeys.keys = [ publicKey ];
    environment.systemPackages = with pkgs; [ rsync tmux nixos-facter ];
    netboot.squashfsCompression = "zstd -Xcompression-level 1";
  };
}
