{ nd, ... }: {
  nd.openttd = {
    nixos =
_@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options = {
    narrowdivergent.programs.openttd.enable = mkEnableOption "install openttd";
  };

  config = mkIf config.narrowdivergent.programs.openttd.enable {
    #  xdg.configFile."emacs/init.el".source = ../files/init.el;
    environment.systemPackages = with pkgs; [ openttd ];
  };
}
;
  };
}
