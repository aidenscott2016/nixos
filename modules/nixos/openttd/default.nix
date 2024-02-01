_@{ lib, pkgs, config, ... }:
with lib;
{

  options = {
    aiden.programs.openttd.enabled = mkEnableOption "install openttd";
  };

  config = mkIf config.aiden.programs.openttd.enabled {
    #  xdg.configFile."emacs/init.el".source = ../files/init.el;
    environment.systemPackages = with pkgs; [ openttd ];

  };

}
