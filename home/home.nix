inputs@{ config, pkgs, lib, ... }:
{
  imports = [
    ./git.nix
    ./tmux
    ./bash
    ./firefox
    ./gpg-agent.nix
  ];
  home.stateVersion = "23.05";

  xdg.enable = true;
  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';
  xdg.configFile."emacs/init.el".source = ./files/init.el;

  programs.ssh.enable = true;
  programs.ssh.matchBlocks."gitlab.com".identityFile = "~/.ssh/gitlab";
  programs.ssh.matchBlocks."github.com".identityFile = "~/.ssh/github";
  programs.ssh.matchBlocks."10.0.4.*".identityFile = "~/.ssh/local";

  home.file."downloads".source = config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
  home.file.".vimrc".source = ./files/vimrc;
  home.file.".ideavimrc".source = ./files/ideavimrc;

}
