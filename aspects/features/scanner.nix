{ lib, ... }:
{
  flake.nixosModules.scanner = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.scanner;
    in {
      options.aiden.modules.scanner.enable = mkEnableOption "scanner support";

      config = mkIf cfg.enable {
        hardware.sane = {
          enable = true;
          extraBackends = [ pkgs.sane-airscan ];
          drivers.scanSnap.enable = true;
        };
        users.users.aiden.extraGroups = [
          "scanner"
          "lp"
        ];
      };
    };
}
