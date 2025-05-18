params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  moduleName = "geoclue";
in
{
  options = {
    aiden.modules.geoclue.enable = mkEnableOption moduleName;
    aiden.modules.geoclue.apps = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            isAllowed = mkOption {
              type = types.bool;
              default = false;
            };
            isSystem = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }
      );
      default = { };
      description = "Applications that need geolocation access";
    };
    aiden.modules.geoclue.staticLocation = mkOption {
      type = types.submodule {
        options = {
          latitude = mkOption {
            type = types.float;
            default = 51.0;
          };
          longitude = mkOption {
            type = types.float;
            default = -1.0;
          };
        };
      };
      default = { };
      description = "Static location configuration when WiFi-based location is disabled";
    };
  };

  config = mkIf config.aiden.modules.geoclue.enable {
    services.geoclue2 = {
      enable = true;
      enableWifi = false;
      appConfig = config.aiden.modules.geoclue.apps;
    };

    environment.etc = lib.mkIf (!config.services.geoclue2.enableWifi) {
      "geolocation".text = ''
        ${toString config.aiden.modules.geoclue.staticLocation.latitude}   # latitude
        ${toString config.aiden.modules.geoclue.staticLocation.longitude}  # longitude
        96           # altitude
        1.83         # accuracy radius
      '';

      "geoclue/conf.d/00-config.conf".text = ''
        [static-source]
        enable=true
      '';
    };
  };
}
