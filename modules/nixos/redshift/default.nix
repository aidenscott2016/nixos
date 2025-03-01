params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "redshift" params {
  services = {
    redshift.enable = true;
    geoclue2.enable = true;
  };
  location.provider = "geoclue2";
  environment.etc = lib.mkIf (!config.services.geoclue2.enableWifi) {
    "geolocation".text = ''
      51.064148701061185   # latitude
      -1.3189842441933493  # longitude
      96           # altitude
      1.83         # accuracy radius
    '';
    "geoclue/conf.d/00-config.conf".text = ''
      [static-source]
      enable=true
    '';
  };
}
