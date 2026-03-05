{ ... }:
{
  flake.modules.nixos.secureboot =
    { lib, pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      security.tpm2.enable = true;
      boot.initrd.systemd.tpm2.enable = true;

      environment.systemPackages = with pkgs; [
        sbctl
        tpm2-tools
        tpm2-tss
      ];
    };
}
