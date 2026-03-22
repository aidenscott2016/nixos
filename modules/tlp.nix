{ ... }:
{
  flake.modules.nixos.tlp =
    { ... }:
    {
      services.auto-cpufreq.enable = false;
      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 80;
          START_CHARGE_THRESH_BAT1 = 75;
          STOP_CHARGE_THRESH_BAT1 = 80;
        };
      };
    };
}
