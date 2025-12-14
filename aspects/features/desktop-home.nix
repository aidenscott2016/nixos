{ lib, ... }:
{
  flake.modules.homeManager.desktop = { config, ... }: {
    home.stateVersion = "23.05";
    xdg.enable = true;

    home.file."downloads".source = config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
  };
}
