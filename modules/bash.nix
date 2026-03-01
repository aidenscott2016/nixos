{ ... }:
{
  flake.modules.homeManager.bash =
    { config, pkgs, ... }:
    {
      programs.bash = {
        enable = true;
        bashrcExtra = ''
          set -o vi
        '';
      };
    };
}
