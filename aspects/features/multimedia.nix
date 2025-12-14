{ lib, ... }:
{
  flake.nixosModules.multimedia = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.multimedia;
    in {
      options.aiden.modules.multimedia.enable = mkEnableOption "multimedia";

      config = mkIf cfg.enable {
        aiden = {
          modules.transmission.enable = false;
          programs.beets.enable = true;
        };

        environment.systemPackages = with pkgs; [
          transmission_4-gtk
          nicotine-plus
          yt-dlp
          vlc
          imagemagick
        ];
      };
    };
}
