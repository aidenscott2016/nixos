_@{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
{
  options = {
    aiden.programs.beets.enable = mkEnableOption "beets";
  };

  config = mkIf config.aiden.programs.beets.enable {
    environment.systemPackages = [ pkgs.beets ];
  };
}
