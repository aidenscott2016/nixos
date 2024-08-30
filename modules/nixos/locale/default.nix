{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aiden.modules.locale;
in
{
  options.aiden.modules.locale = {
    enabled = mkEnableOption "Locale";
  };

  config = mkIf cfg.enabled {

    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    time.timeZone = "Europe/London";
    services.xserver = {
      layout = "gb";
      xkbOptions = "caps:swapescape";
      libinput.enable = true;
    };

    i18n = {
      defaultLocale = "en_GB.UTF-8";
    };
  };
}
