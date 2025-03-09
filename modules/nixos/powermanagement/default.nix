params@{ pkgs, lib, config, ... }:
with lib;
let cfg = config.aiden.modules.powermanagement;
in {
  options.aiden.modules.powermanagement = {
    enabled = mkEnableOption "powermanagement";
  };
  config = mkIf cfg.enabled {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };
}
