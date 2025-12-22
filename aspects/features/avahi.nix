{ lib, ... }:
{
  flake.modules.nixos.avahi = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.avahi;
    in {
      options.aiden.modules.avahi.enable = mkEnableOption "avahi";

      config = mkIf cfg.enable {
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          publish = {
            enable = true;
            addresses = true;
            workstation = true;
          };
          openFirewall = true;
        };
      };
    };
}
