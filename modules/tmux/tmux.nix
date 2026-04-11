{ ... }:
{
  flake.modules.homeManager.tmux =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.fzf ];
      programs.tmux = {
        enable = true;
        extraConfig = builtins.readFile ./tmux.conf;
        plugins = with pkgs.tmuxPlugins; [
          yank
          extrakto
        ];
      };
    };
}
