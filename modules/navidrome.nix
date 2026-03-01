{ ... }:
{
  flake.modules.nixos.navidrome =
    { lib, pkgs, config, ... }:
    with lib;
    {
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
