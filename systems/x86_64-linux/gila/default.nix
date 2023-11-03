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

  networking.firewall.enable = true; # !!!!!
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

    interfaces.br0 = {
      ipv4.addresses = [{
        address = "10.0.0.1";
        prefixLength = 24;
      }];
    };

    bridges.br0 = { interfaces = [ "eth1" "eth2" ]; };

    nat.enable = true;
    nat.externalInterface = "eth0";
    nat.internalInterfaces = [ "br0" ];
  };

  services.kea = {
    dhcp6.enable = false;
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = { interfaces = [ "br0" ]; };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        subnet4 = [{
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
        }];
        valid-lifetime = 4000;
      };
    };

  };

  # services.dhcpd4 = {
  #   enable = true;
  #   extraConfig = ''
  #     option subnet-mask 255.255.255.0;
  #     option routers 10.0.0.1;
  #     option domain-name-servers 10.0.0.1;
  #     subnet 10.0.0.0 netmask 255.255.255.0 {
  #         range 10.0.0.100 10.0.0.199;
  #     }
  #   '';
  #   interfaces = [ "br0" ];
  # };
}
