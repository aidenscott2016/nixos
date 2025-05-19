{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (config.aiden.modules.router)
    enable
    internalInterface
    externalInterface
    ;
in
{
  config = mkIf enable {
    networking = {
      vlans = {
        # GS308E doesn't support admin vlan
        # Can't find a way that lets router hit management interface as well as wifi
        # admin = {
        #   interface = internalInterface;
        #   id = 1;
        # };
        lan = {
          interface = internalInterface;
          id = 101;
        };
        iot = {
          interface = internalInterface;
          id = 102;
        };
        guest = {
          interface = internalInterface;
          id = 103;
        };
      };
      interfaces = {
        ${externalInterface} = {
          useDHCP = true;
        };
        ${internalInterface} = {
          ipv4.addresses = [
            {
              address = "10.0.0.1";
              prefixLength = 24;
            }
            {
              address = "10.0.0.2";
              prefixLength = 24;
            }
          ];
          useDHCP = false;
        };
        # admin = {
        #   ipv4.addresses = [
        #     {
        #       address = "10.0.0.1";
        #       prefixLength = 24;
        #     }
        #   ];
        # };
        lan = {
          ipv4.addresses = [
            {
              address = "10.0.1.1";
              prefixLength = 24;
            }
          ];
        };
        iot = {
          ipv4.addresses = [
            {
              address = "10.0.2.1";
              prefixLength = 24;
            }
          ];
        };
        guest = {
          ipv4.addresses = [
            {
              address = "10.0.3.1";
              prefixLength = 24;
            }
          ];
        };
        eth3 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "10.0.4.1";
              prefixLength = 24;
            }
          ];
        };
      };
    };
  };
}
