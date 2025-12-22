{ lib, ... }:
{
  flake.modules.homeManager.desktop = { config, ... }: {
    home.stateVersion = "23.05";
    xdg.enable = true;

    home.file."downloads".source = config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";

    services.sxhkd = {
      enable = true;
      keybindings = {
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioNext" = "playerctl next";
        "XF86AudioPrev" = "playerctl previous";
        "XF86AudioStop" = "playerctl stop";
      };
    };
  };
}
