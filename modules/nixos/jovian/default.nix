params@{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  moduleName = "jovian";
  cfg = config.aiden.modules.${moduleName};
in
{
  imports = [ inputs.jovian.nixosModules.default ];
  options = {
    aiden.modules.${moduleName}.enable = mkEnableOption moduleName;
  };
  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    jovian = {
      hardware = {
        has.amd.gpu = true;
        amd.gpu.enableBacklightControl = false;
      };
      steam = {
        updater.splash = "vendor";
        enable = true;
        autoStart = true;
        user = "aiden";
        desktopSession = "plasma";
      };
      steamos = {
        useSteamOSConfig = true;
      };
    };
  };
}
