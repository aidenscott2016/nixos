params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.aiden.modules.powermanagement;
in
{
  options.aiden.modules.powermanagement = {
    enable = mkEnableOption "powermanagement";
  };
  config = mkIf cfg.enable {
    services.auto-cpufreq.enable = false;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT1 = 75;
        STOP_CHARGE_THRESH_BAT1 = 80;
      };
    };
  };
}
