params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "navidrome";
  cfg = config.aiden.modules.${moduleName};
in
{
  options = {
    aiden.modules.${moduleName}.enable = mkEnableOption moduleName;
  };
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
}
