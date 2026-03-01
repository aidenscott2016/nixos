{ ... }:
{
  flake.modules.nixos.locale =
    { config, lib, ... }:
    with lib;
    {
      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
      time.timeZone = "Europe/London";
      services.xserver = {
        xkb = {
          layout = "gb";
          options = "caps:swapescape";
        };
      };
      services.libinput.enable = true;

      i18n = {
        defaultLocale = "en_GB.UTF-8";
      };
    };
}
