{ lib, ... }:
{
  flake.homeManagerModules.tmux = { ... }: {
    programs.tmux.enable = true;
    xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;
  };
}
