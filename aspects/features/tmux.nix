{ lib, ... }:
{
  flake.modules.homeManager.tmux = { ... }: {
    programs.tmux.enable = true;
    xdg.configFile."tmux/tmux.conf".source = ../../modules/home/tmux/tmux.conf;
  };
}
