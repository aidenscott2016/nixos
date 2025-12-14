{ lib, ... }:
{
  flake.nixosModules.beets = { config, lib, pkgs, inputs, ... }:
    with lib;
    let
      cfg = config.aiden.programs.beets;
      beet-override = with pkgs; (beets.override {
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
    in {
      options.aiden.programs.beets.enable = mkEnableOption "beets music library manager";

      config = mkIf cfg.enable {
        environment.systemPackages = [ beet-override ];
      };
    };
}
