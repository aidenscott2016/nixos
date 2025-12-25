{ inputs, ... }:
{
  aiden.beets.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.beets or { };
      beet-override = pkgs.beets.override {
        pluginOverrides = {
          fetchart.enable = true;
          bandcamp = {
            enable = true;
            propagatedBuildInputs = [ inputs.self.packages.x86_64-linux.beetcamp ];
          };
          discogs.enable = true;
          copyartifacts = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beetsPackages.copyartifacts ];
          };
        };
      };
    in
    {
      options.aiden.aspects.beets = {
        enable = mkEnableOption "Beets music library manager";
      };

      config = mkIf (cfg.enable or false) {
        environment.systemPackages = [ beet-override ];
      };
    };
}
