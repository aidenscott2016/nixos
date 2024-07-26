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

      extraLocaleSettings = {
        LC_ADDRESS = "en_GB.UTF-8";
        LC_IDENTIFICATION = "en_GB.UTF-8";
        LC_MEASUREMENT = "en_GB.UTF-8";
        LC_MONETARY = "en_GB.UTF-8";
        LC_NAME = "en_GB.UTF-8";
        LC_NUMERIC = "en_GB.UTF-8";
        LC_PAPER = "en_GB.UTF-8";
        LC_TELEPHONE = "en_GB.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
    };
  };
}
