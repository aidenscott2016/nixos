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
          ExtAuth.TrustedSources = "127.0.0.1/32";
          ExtAuth.LogoutURL = "https://auth.sw1a1aa.uk/logout";
          EnableUserEditing = false;
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
