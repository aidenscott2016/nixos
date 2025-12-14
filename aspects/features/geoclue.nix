{ lib, ... }:
{
  flake.nixosModules.geoclue = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.geoclue;
    in {
      options.aiden.modules.geoclue = {
        enable = mkEnableOption "geoclue";
        apps = mkOption {
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
        staticLocation = mkOption {
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

      config = mkIf cfg.enable {
        services.geoclue2 = {
          enable = true;
          enableWifi = false;
          appConfig = cfg.apps;
        };

        environment.etc = mkIf (!config.services.geoclue2.enableWifi) {
          "geolocation".text = ''
            ${toString cfg.staticLocation.latitude}   # latitude
            ${toString cfg.staticLocation.longitude}  # longitude
            96           # altitude
            1.83         # accuracy radius
          '';

          "geoclue/conf.d/00-config.conf".text = ''
            [static-source]
            enable=true
          '';
        };
      };
    };
}
