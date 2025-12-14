{ lib, ... }:
{
  flake.homeManagerModules.bash = { ... }: {
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        set -o vi
      '';
    };
  };
}
