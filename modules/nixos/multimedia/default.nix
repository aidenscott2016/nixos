params@{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    aiden.modules.multimedia.enable = lib.mkEnableOption "multimedia";
  };
  config = lib.mkIf config.aiden.modules.multimedia.enable {
    aiden = {
      modules.transmission.enable = false;
      programs.beets.enable = true;
    };

    environment.systemPackages = with pkgs; [
      transmission_3-gtk
      nicotine-plus
      yt-dlp
      vlc
      (jellyfin-media-player.override { withDbus = false; })
      imagemagick
    ];
  };
}
