inputs@{ config, pkgs, lib, ... }: {
  home.stateVersion = "23.05";

  xdg.enable = true;
  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';

  #xdg.configFile."emacs/init.el".source = ../files/init.el;

  home.file."downloads".source =
    config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
  home.file.".vimrc".source = ../files/vimrc;
  home.file.".ideavimrc".source = ../files/ideavimrc;

}
