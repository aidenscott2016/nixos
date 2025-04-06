_@{ lib, pkgs, config, ... }:
with lib; {
  options = {
    aiden.programs.openttd.enable = mkEnableOption "install openttd";
  };

  config = mkIf config.aiden.programs.openttd.enable {
    #  xdg.configFile."emacs/init.el".source = ../files/init.el;
    environment.systemPackages = with pkgs; [ openttd ];
  };
}
