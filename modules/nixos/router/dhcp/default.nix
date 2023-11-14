{ config, lib, pkgs, ... }:
with lib;
let enabled = config.aiden.modules.router.enabled;
in {
  config = mkIf enabled {
    services.kea = {
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
              pools = [{ pool = "10.0.0.100 - 10.0.0.199"; }];
              subnet = "10.0.0.0/24";
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "10.0.0.1";
                }
                {
                  name = "routers";
                  data = "10.0.0.1";
                }
              ];
            }
            {
              interface = "iot";
              pools = [{ pool = "10.0.1.100 - 10.0.1.199"; }];
              subnet = "10.0.1.0/24";
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "10.0.1.1";
                }
                {
                  name = "routers";
                  data = "10.0.1.1";
                }
              ];
            }
            {
              interface = "guest";
              pools = [{ pool = "10.0.2.100 - 10.0.2.199"; }];
              subnet = "10.0.2.0/24";
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "10.0.2.1";
                }
                {
                  name = "routers";
                  data = "10.0.2.1";
                }
              ];
            }
            {
              interface = "eth3";
              pools = [{ pool = "10.0.3.100 - 10.0.3.199"; }];
              subnet = "10.0.3.0/24";
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "10.0.3.1";
                }
                {
                  name = "routers";
                  data = "10.0.3.1";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
