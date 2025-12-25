{
  aiden.navidrome.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.navidrome or { };
    in
    {
      options.aiden.aspects.navidrome = {
        enable = mkEnableOption "Navidrome music streaming server";
        musicFolder = mkOption {
          type = types.str;
          default = "/media/t7/Music/library/";
          description = "Path to the music folder";
        };
      };

      config = mkIf (cfg.enable or false) {
        services.navidrome = {
          group = "video";
          enable = true;
          settings = {
            MusicFolder = cfg.musicFolder;
          };
        };

        # Auto-add to reverse proxy if enabled
        aiden.aspects.reverse-proxy.apps = mkIf (config.aiden.aspects.reverse-proxy.enable or false) [
          {
            name = "navidrome";
            port = 4533;
          }
        ];
      };
    };
}
