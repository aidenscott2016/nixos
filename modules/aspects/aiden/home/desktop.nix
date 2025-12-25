{ ... }:
{
  aiden.home.desktop.nixos = { config, ... }: {
    home-manager.users.aiden = {
      home.stateVersion = "23.05";
      xdg.enable = true;

      home.file."downloads".source = config.home-manager.users.aiden.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
    };
  };
}
