{ lib, ... }:
{
  flake.modules.homeManager.bash = { ... }: {
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        set -o vi
      '';
    };
  };
}
