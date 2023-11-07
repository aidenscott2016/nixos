{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    inputs.disko.nixosModules.default
    ./disko-config.nix
  ];

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" "10.0.0.1" ];
        access-control =
          [ "0.0.0.0/0 refuse" "127.0.0.0/8 allow" "10.0.0.1/24 allow" ];
      };
    };
  };

  networking.hostName = "gila";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;
  networking.usePredictableInterfaceNames = true;

  networking.firewall.enable = false; # !!!!!
  networking.firewall.interfaces.eth0.allowedTCPPorts = [ ];
  networking.firewall.interfaces.eth0.allowedUDPPorts = [ ];
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 53 22 ];

  networking.firewall.interfaces.br0.allowedUDPPorts = [ 53 ];
  networking = {
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    interfaces.eth0.useDHCP = true;

    nat.enable = true;
    nat.externalInterface = "eth0";
    nat.internalInterfaces = [ "eth1" "lan" ];

    interfaces = {

      lan = {
        ipv4.addresses = [{
          address = "10.0.0.2";
          prefixLength = 24;
        }];
      };
      eth1 = {
        ipv4.addresses = [{
          address = "10.0.0.1";
          prefixLength = 24;
        }];
      };
    };

    vlans = {
      lan = {
        interface = "eth1";
        id = 101;
      };
    };

  };

  services.kea = {
    dhcp6.enable = false;
    dhcp4 = {
      enable = false;
      settings = {
        interfaces-config = { interfaces = [ "eth1" "lan" ]; };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        subnet4 = [
          {
            interface = "lan";
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
            interface = "eth1";
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
        ];
        valid-lifetime = 4000;
      };
    };

  };
  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      subnet 10.0.0.0 netmask 255.255.255.0 {
        option broadcast-address 10.0.0.255;
        option routers 10.0.0.1;
        option domain-name-servers 10.0.0.1;
        option subnet-mask 255.255.255.0;
        interface eth1;
        range 10.0.0.50 10.0.0.99;
      }


      subnet 10.0.1.0 netmask 255.255.255.0 {
        option broadcast-address 10.0.1.255;
        option routers 10.0.1.1;
        option domain-name-servers 10.0.1.1;
        option subnet-mask 255.255.255.0;
        interface lan;
        range 10.0.1.50 10.0.1.99;
      }
    '';
    interfaces = [ "eth1" "lan" ];
  };

  environment.systemPackages = [ pkgs.tcpdump pkgs.dnsutils ];
}
