{ config, pkgs, ... }:
{
  imports = [ ./git.nix ./tmux ./bash ];
  home.stateVersion = "23.05";

  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';

}

