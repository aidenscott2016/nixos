{ config, pkgs, ... }:
{
  imports = [ ./git.nix ./tmux ./bash ];
  home.stateVersion = "23.05";

  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';
  xdg.configFile."emacs/init.el".source = ./files/init.el;
  xdg.enable = true;

  programs.ssh.enable = true;
  programs.ssh.matchBlocks."gitlab.com".identityFile = "~/.ssh/gitlab";
  programs.ssh.matchBlocks."10.0.4.*".identityFile = "~/.ssh/local";
}
