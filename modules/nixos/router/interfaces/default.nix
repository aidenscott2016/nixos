{ config, lib, pkgs, ... }:
with lib;
let
  inherit (config.aiden.modules.router)
    enabled internalInterface externalInterface;
in {
  config = mkIf enabled {
    networking = {
      vlans = {
        lan = {
          interface = internalInterface;
          id = 100;
        };
        iot = {
          interface = internalInterface;
          id = 101;
        };
        guest = {
          interface = internalInterface;
          id = 102;
        };
      };
      interfaces = {
        ${externalInterface} = { useDHCP = true; };
        ${internalInterface} = { useDHCP = false; };
        lan = {
          ipv4.addresses = [{
            address = "10.0.0.1";
            prefixLength = 24;
          }];
        };
        iot = {
          ipv4.addresses = [{
            address = "10.0.1.1";
            prefixLength = 24;
          }];
        };
        guest = {
          ipv4.addresses = [{
            address = "10.0.2.1";
            prefixLength = 24;
          }];
        };
        eth3 = {
          useDHCP = false;
          ipv4.addresses = [{
            address = "10.0.3.1";
            prefixLength = 24;
          }];
        };
      };
    };
  };
}
