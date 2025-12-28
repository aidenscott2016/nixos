_@{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  beet-override =
    with pkgs;
    (beets.override {
      pluginOverrides = {
        fetchart.enable = true;
        bandcamp = {
          enable = true;
          propagatedBuildInputs = [ inputs.self.packages.x86_64-linux.beetcamp ];
        };
        discogs.enable = true;
        copyartifacts = {
          enable = true;
          propagatedBuildInputs = [ beetsPackages.copyartifacts ];
        };
      };
    });
in
{
  options = {
    narrowdivergent.programs.beets.enable = mkEnableOption "beets";
  };

  config = mkIf config.narrowdivergent.programs.beets.enable {
    environment.systemPackages = [ beet-override ];
  };
}
