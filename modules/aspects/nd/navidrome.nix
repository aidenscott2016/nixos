{ nd, ... }: {
  nd.navidrome = {
    nixos =
{ lib, pkgs, config, ... }:
{
  config = {
    services.navidrome = {
      group = "video";
      enable = true;
      settings = {
        MusicFolder = "/media/t7/Music/library/";
      };
    };

    narrowdivergent.aspects.reverseProxy = {
      apps = [
        {
          name = "navidrome";
          port = 4533;
        }
      ];
    };
  };
}
;
  };
}
