{ ... }:
{
  flake.modules.nixos.multimedia =
    { pkgs, lib, config, ... }:
    {
      environment.systemPackages = with pkgs; [
        transmission_4-gtk
        nicotine-plus
        yt-dlp
        vlc
        imagemagick
      ];
    };
}
