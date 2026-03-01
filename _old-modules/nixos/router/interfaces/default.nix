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
    systemd.network.enable = true;
    networking.useNetworkd = true;

    systemd.network = {
      netdevs = {
        # Bridge to trunk enp2s0 and enp3s0 together
        "10-bridge0" = {
          netdevConfig = {
            Name = "bridge0";
            Kind = "bridge";
          };
        };

        # GS308E doesn't support admin vlan
        # Can't find a way that lets router hit management interface as well as wifi
        "20-admin" = {
          netdevConfig = {
            Name = "admin";
            Kind = "vlan";
          };
          vlanConfig = {
            Id = 100;
          };
        };
        "20-lan" = {
          netdevConfig = {
            Name = "lan";
            Kind = "vlan";
          };
          vlanConfig = {
            Id = 101;
          };
        };
        "20-iot" = {
          netdevConfig = {
            Name = "iot";
            Kind = "vlan";
          };
          vlanConfig = {
            Id = 102;
          };
        };
        "20-guest" = {
          netdevConfig = {
            Name = "guest";
            Kind = "vlan";
          };
          vlanConfig = {
            Id = 103;
          };
        };
      };

      networks = {
        "30-${externalInterface}" = {
          matchConfig = {
            Name = externalInterface;
          };
          networkConfig = {
            DHCP = "yes";
          };
        };

        # Add enp2s0 to bridge
        "30-${internalInterface}" = {
          matchConfig = {
            Name = internalInterface;
          };
          networkConfig = {
            Bridge = "bridge0";
          };
        };

        # Add enp3s0 to bridge
        "30-enp3s0" = {
          matchConfig = {
            Name = "enp3s0";
          };
          networkConfig = {
            Bridge = "bridge0";
          };
        };

        # Configure bridge with VLANs
        "30-bridge0" = {
          matchConfig = {
            Name = "bridge0";
          };
          address = [
            "10.0.4.1/24"
          ];
          networkConfig = {
            DHCP = "no";
          };
          vlan = [
            "lan"
            "guest"
            "iot"
            "admin"
          ];
          linkConfig.RequiredForOnline = "carrier";
        };

        "40-admin" = {
          matchConfig = {
            Name = "admin";
          };
          address = [
            "10.0.0.1/24"
          ];
          networkConfig = {
            DHCP = "no";
          };
        };

        "40-lan" = {
          matchConfig = {
            Name = "lan";
          };
          address = [
            "10.0.1.1/24"
          ];
          networkConfig = {
            DHCP = "no";
          };
        };

        "40-iot" = {
          matchConfig = {
            Name = "iot";
          };
          address = [
            "10.0.2.1/24"
          ];
          networkConfig = {
            DHCP = "no";
          };
        };

        "40-guest" = {
          matchConfig = {
            Name = "guest";
          };
          address = [
            "10.0.3.1/24"
          ];
          networkConfig = {
            DHCP = "no";
          };
        };

      };
    };
  };
}
