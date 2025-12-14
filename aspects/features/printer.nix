{ lib, ... }:
{
  flake.nixosModules.printer = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.printer;
    in {
      options.aiden.modules.printer.enable = mkEnableOption "printer";

      config = mkIf cfg.enable {
        services = {
          avahi.enable = true;
          avahi.nssmdns4 = true;
          printing = {
            enable = true;
            drivers = [ pkgs.hplip ];
          };
        };
      };
    };
}
