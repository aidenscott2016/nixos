{ lib, ... }:
{
  flake.homeManagerModules.tmux = { ... }: {
    programs.tmux.enable = true;
    xdg.configFile."tmux/tmux.conf".source = ../../modules/home/tmux/tmux.conf;
  };
}
