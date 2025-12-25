{
  aiden.geoclue.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.geoclue or { };
    in
    {
      options.aiden.aspects.geoclue = {
        enable = mkEnableOption "Geoclue location services";
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

      config = mkIf (cfg.enable or false) {
        services.geoclue2 = {
          enable = true;
          enableWifi = false;
          appConfig = cfg.apps;
        };

        environment.etc = lib.mkIf (!config.services.geoclue2.enableWifi) {
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
