params@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "yubikey";
in {
  options = {
    aiden.modules."${moduleName}".enabled = mkEnableOption moduleName;
  };
  config = mkIf config.aiden.modules."${moduleName}".enabled {

    # smart card
    services.pcscd.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [ yubikey-manager ];
  };
}
