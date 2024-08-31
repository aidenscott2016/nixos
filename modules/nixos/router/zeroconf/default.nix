{ config, lib, pkgs, ... }:
with lib;
let enabled = config.aiden.modules.router.enabled;
in {
  config = mkIf enabled {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      reflector = true;
      allowInterfaces = [ "lan" "iot" "wlan" "guest" "eth3" ];
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      openFirewall = true;
    };
  };
}
