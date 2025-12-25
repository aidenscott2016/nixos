{ ... }:
{
  aiden.home.tmux.nixos = {
    home-manager.users.aiden = {
      programs.tmux.enable = true;
      xdg.configFile."tmux/tmux.conf".source = ./tmux/tmux.conf;
    };
  };
}
