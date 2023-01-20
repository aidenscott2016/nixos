{ config, pkgs, ... }:
{
  xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;
}
