{ lib, ... }:
{
  flake.nixosModules.gc = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.gc;
    in {
      options.aiden.modules.gc.enable = mkEnableOption "garbage collection";

      config = mkIf cfg.enable {
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };
    };
}
