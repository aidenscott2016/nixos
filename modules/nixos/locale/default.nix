{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.aiden.modules.locale;
in
{
  options.aiden.modules.locale = {
    enable = mkEnableOption "Locale";
  };

  config = mkIf cfg.enable {

    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    time.timeZone = "Europe/London";
    services.xserver = {
      xkb = {
        layout = "gb";
        options = mkIf (!config.aiden.modules.keyd.enable)  "caps:swapescape";
      };
    };
    services.libinput.enable = true;

    i18n = {
      defaultLocale = "en_GB.UTF-8";
    };
  };
}
