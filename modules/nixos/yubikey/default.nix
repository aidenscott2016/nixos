params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  moduleName = "yubikey";
in
{
  options = {
    aiden.modules."${moduleName}".enable = mkEnableOption moduleName;
  };

  config = mkIf config.aiden.modules."${moduleName}".enable {
    # smart card
    services.pcscd.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [ yubikey-manager ];
  };
}
