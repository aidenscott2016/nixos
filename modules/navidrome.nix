{ ... }:
{
  flake.modules.nixos.navidrome =
    { lib, pkgs, config, ... }:
    with lib;
    {
      services.navidrome = {
        enable = true;
        settings = {
          MusicFolder = "/srv/media/Music/library/";
        };
      };

      systemd.services.navidrome.after = [ "media-bindfs.service" ];

      # Subsonic API (/rest/*) bypassed in Authelia access_control
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
