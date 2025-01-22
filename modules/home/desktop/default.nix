inputs@{ config, pkgs, lib, ... }: {
  home.stateVersion = "23.05";

  xdg.enable = true;
  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';

  #xdg.configFile."emacs/init.el".source = ../files/init.el;

  home.file."downloads".source =
    config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
  home.file.".vimrc".source = ../files/vimrc;
  home.file.".ideavimrc".source = ../files/ideavimrc;

  # nvironment.pathsToLink =[ "/share/xdg-desktop-portal" "/share/applications" ];
  xdg.portal.enable = true;
  xdg.portal.config = {
    common = {
      default = "gtk";
      "org.freedesktop.impl.portal.Settings" = "darkman";
      "org.freedesktop.impl.portal.Secrets" = "none";
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };
  };
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.darkman ];
  xdg.portal.xdgOpenUsePortal = true;
  services.darkman.enable = true;
}
