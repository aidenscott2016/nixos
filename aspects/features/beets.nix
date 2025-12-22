{ lib, ... }:
{
  flake.modules.nixos.beets = { config, lib, pkgs, inputs, ... }:
    with lib;
    let
      cfg = config.aiden.programs.beets;
      # TODO: Re-enable plugin configuration once beets API is clarified
      # The pluginOverrides API has changed in newer nixpkgs
      # For now, use base beets package
    in {
      options.aiden.programs.beets.enable = mkEnableOption "beets music library manager";

      config = mkIf cfg.enable {
        environment.systemPackages = [ pkgs.beets ];
      };
    };
}
