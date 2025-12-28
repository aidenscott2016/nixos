{ nd, ... }: {
  nd.multimedia = {
    includes = [
      nd.transmission
      nd.beets
    ];

    nixos =
{
  pkgs,
  lib,
  config,
  ...
}:
{

  config = {
    narrowdivergent = {
      programs.beets.enable = true;
    };

    environment.systemPackages = with pkgs; [
      transmission_4-gtk
      nicotine-plus
      yt-dlp
      vlc
      #(jellyfin-media-player.override { withDbus = false; })
      imagemagick
    ];
  };
}
;
  };
}
