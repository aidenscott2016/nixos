{ ... }:
{
  flake.modules.nixos.router-interfaces =
    { lib, pkgs, config, ... }:
    with lib;
    let
      inherit (config.aiden.modules.router)
        internalInterface
        externalInterface;
    in
    {
      config = {
        systemd.network.enable = true;
        networking.useNetworkd = true;

        systemd.network = {
          netdevs = {
            "10-bridge0" = {
              netdevConfig = {
                Name = "bridge0";
                Kind = "bridge";
              };
            };

            # Bridge joining VLAN 105 (WiFi) and enp3s0 (wired) for work devices
            "10-work-br" = {
              netdevConfig = {
                Name = "work-br";
                Kind = "bridge";
              };
            };

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
            "20-work" = {
              netdevConfig = {
                Name = "work";
                Kind = "vlan";
              };
              vlanConfig = {
                Id = 105;
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

            "30-${internalInterface}" = {
              matchConfig = {
                Name = internalInterface;
              };
              networkConfig = {
                Bridge = "bridge0";
              };
            };

            # enp3s0 (wired work devices) is a bridge port of work-br
            "30-enp3s0" = {
              matchConfig = {
                Name = "enp3s0";
              };
              networkConfig = {
                Bridge = "work-br";
              };
            };

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
                "work"
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

            # work VLAN sub-interface is a bridge port of work-br
            "40-work" = {
              matchConfig = {
                Name = "work";
              };
              networkConfig = {
                Bridge = "work-br";
              };
            };

            # work-br carries 10.0.5.0/24 for both WiFi (VLAN 105) and wired work devices
            "40-work-br" = {
              matchConfig = {
                Name = "work-br";
              };
              address = [
                "10.0.5.1/24"
              ];
              networkConfig = {
                DHCP = "no";
              };
            };
          };
        };
      };
    };
}
