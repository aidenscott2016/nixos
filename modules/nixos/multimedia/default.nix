{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../transmission/default.nix
    ../beets/default.nix
  ];

  config = {
    aiden = {
      modules.transmission.enable = false;
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
