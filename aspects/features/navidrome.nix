{ lib, ... }:
{
  flake.nixosModules.navidrome = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.navidrome;
    in {
      options.aiden.modules.navidrome.enable = mkEnableOption "navidrome music streaming server";

      config = mkIf cfg.enable {
        services.navidrome = {
          group = "video";
          enable = true;
          settings = {
            MusicFolder = "/media/t7/Music/library/";
          };
        };

        aiden.modules.reverseProxy = {
          apps = [
            {
              name = "navidrome";
              port = 4533;
            }
          ];
        };
      };
    };
}
