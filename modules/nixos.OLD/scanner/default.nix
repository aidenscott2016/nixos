params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "scanner";
  cfg = config.aiden.modules.${moduleName};
in
{
  options = {
    aiden.modules.${moduleName}.enable = mkEnableOption moduleName;
  };
  config = mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      drivers.scanSnap.enable = true;
    };
    users.users.aiden.extraGroups = [
      "scanner"
      "lp"
    ];

  };
}
