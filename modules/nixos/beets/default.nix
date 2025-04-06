_@{ lib, pkgs, config, ... }:
with lib;
let
  beet-override = with pkgs;
    (beets.override {
      pluginOverrides = {
        #fetchart
        discogs.enable = true;
        copyartifacts = {
          enable = true;
          propagatedBuildInputs = [ beetsPackages.copyartifacts ];
        };
      };
    });
in {
  options = {
    aiden.programs.beets.enable = mkEnableOption "beets";
  };

  config = mkIf config.aiden.programs.beets.enable {
    environment.systemPackages = [ beet-override ];
  };
} 