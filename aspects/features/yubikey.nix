{ lib, ... }:
{
  flake.modules.nixos.yubikey = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.yubikey;
    in {
      options.aiden.modules.yubikey.enable = mkEnableOption "yubikey";

      config = mkIf cfg.enable {
        services.pcscd.enable = true;
        security.polkit.enable = true;
        environment.systemPackages = with pkgs; [ yubikey-manager ];
      };
    };
}
