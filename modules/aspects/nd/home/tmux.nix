{ nd, ... }: {
  nd.home.tmux = {
    homeManager = { config, pkgs, ... }: {
      programs.tmux.enable = true;
      xdg.configFile."tmux/tmux.conf".source = ../../../_home/tmux/tmux.conf;
    };
  };
}
