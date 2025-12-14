{ lib, ... }:
{
  flake.nixosModules.redshift = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.redshift;
    in {
      options.aiden.modules.redshift.enable = mkEnableOption "redshift";

      config = mkIf cfg.enable {
        services = {
          redshift.enable = true;
          geoclue2.enable = true;
        };
        location.provider = "geoclue2";
      };
    };
}
