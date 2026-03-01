{ ... }:
{
  flake.modules.nixos.router-zeroconf =
    { lib, pkgs, config, ... }:
    with lib;
    let
      enable = config.aiden.modules.router.enable;
    in
    {
      config = mkIf enable {
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          reflector = true;
          allowInterfaces = [
            "lan"
            "iot"
            "wlan"
            "guest"
            "eth3"
          ];
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
