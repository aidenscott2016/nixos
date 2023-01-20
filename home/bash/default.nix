{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      set -o vi
    '';

  };

  # programs.readline = {
  #   extraConfig = ''
  #     set -o vi
  #   '';
  # };

}
