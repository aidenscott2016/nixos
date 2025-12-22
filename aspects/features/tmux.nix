{ lib, ... }:
{
  flake.modules.homeManager.tmux = { ... }: {
    programs.tmux.enable = true;
    xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;
  };
}
