inputs@{ config, pkgs, ... }:
let
  beet-override = with pkgs;
    (beets.override {
      pluginOverrides = {
        copyartifacts = {
          enable = true;
          propagatedBuildInputs = [ beetsPackages.copyartifacts ];
        };
      };
    });
in {
  environment.systemPackages = with pkgs; [
    beet-override
    nicotine-plus
    yt-dlp
    vlc
    spotify
  ];
}
