{ config, lib, pkgs, ... }:
with lib;
let
  keaEnabled = config.aiden.modules.router.kea.enabled;
  dnsmasqEnabled = config.aiden.modules.router.dnsmasq.enabled;
in
{
  config = {
    services.dnsmasq = mkIf dnsmasqEnabled {
      enable = true;
      settings = {
        domain = "oldstreetjournal.co.uk";
        #dhcp-range = "set:vlan99,10.0.1.100,10.0.1.255,12h";
        dhcp-range = [
          "interface:lan,10.0.1.200,10.0.1.250,255.255.255.0"
          "interface:guest,10.0.2.200,10.0.2.250,255.255.255.0"
        ];
        dhcp-option = [
          "lan,option:router,10.0.1.1"
          "lan,option:dns-server,10.0.0.1"
          "guest,option:router,10.0.3.1"
          "guest,option:dns-server,10.0.0.1"
        ];

      };
    };
    services.kea = mkIf keaEnabled {
      dhcp6.enable = false;
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = { interfaces = [ "lan" "iot" "guest" "eth3" ]; };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          subnet4 = [
            {
              interface = "lan";
              pools = [{ pool = "10.0.1.100 - 10.0.1.199"; }];
              subnet = "10.0.1.0/24";
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "10.0.0.2";
                }
                {
                  name = "routers";
                  data = "10.0.1.1";
                }
              ];
            }
            # {
            #   interface = "iot";
            #   pools = [{ pool = "10.0.2.100 - 10.0.2.199"; }];
            #   subnet = "10.0.1.0/24";
            #   option-data = [
            #     {
            #       name = "domain-name-servers";
            #       data = "10.0.1.1";
            #     }
            #     {
            #       name = "routers";
            #       data = "10.0.1.1";
            #     }
            #   ];
            # }
            # {
            #   interface = "guest";
            #   pools = [{ pool = "10.0.2.100 - 10.0.2.199"; }];
            #   subnet = "10.0.2.0/24";
            #   option-data = [
            #     {
            #       name = "domain-name-servers";
            #       data = "10.0.2.1";
            #     }
            #     {
            #       name = "routers";
            #       data = "10.0.2.1";
            #     }
            #   ];
            # }
            # {
            #   interface = "eth3";
            #   pools = [{ pool = "10.0.3.100 - 10.0.3.199"; }];
            #   subnet = "10.0.3.0/24";
            #   option-data = [
            #     {
            #       name = "domain-name-servers";
            #       data = "10.0.3.1";
            #     }
            #     {
            #       name = "routers";
            #       data = "10.0.3.1";
            #     }
            #   ];
            # }
          ];
        };
      };
    };
  };
}
