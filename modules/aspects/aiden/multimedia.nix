{
  aiden.multimedia.nixos =
    { pkgs, ... }:
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
