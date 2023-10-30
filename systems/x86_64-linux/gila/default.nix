{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    ./disko-config.nix
  ];

  aiden.modules.common.enabled = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gila";
  networking.networkmanager.enable = true;

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;

  system.stateVersion = lib.mkForce "23.05";

  powerManagement.cpuFreqGovernor = "ondemand";

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [ "copytoram" ];
  boot.supportedFilesystems =
    pkgs.lib.mkForce [ "btrfs" "vfat" "xfs" "ntfs" "cifs" ];

  services.irqbalance.enable = true;

  networking.dhcpcd.enable = true;
  networking.usePredictableInterfaceNames = true;
  networking.firewall.enable = false;
  networking.firewall.interfaces.eth0.allowedTCPPorts = [ 4949 ];
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.br0.allowedUDPPorts = [ 53 ];

  services.acpid.enable = true;

  services.unbound = {
    enable = false;
    settings = {
      server = {
        interface = [ "127.0.0.1" "10.42.42.42" ];
        access-control =
          [ "0.0.0.0/0 refuse" "127.0.0.0/8 allow" "10.42.42.0/24 allow" ];
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;

  };

  networking = {
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    interfaces.eth0 = { };

    interfaces.br0 = {
      ipv4.addresses = [{
        address = "10.0.0.1";
        prefixLength = 24;
      }];
    };

    interfaces.eth3 = {
      useDHCP = true;
      ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };

    bridges.br0 = { interfaces = [ "eth1" "eth2" ]; };

    nat.enable = true;
    nat.externalInterface = "eth0";
    nat.internalInterfaces = [ "br0" ];
  };

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      option routers 10.0.0.1;
      option domain-name-servers 10.0.0.1, 9.9.9.9;
      subnet 10.0.0.1 netmask 255.255.255.0 {
          range 10.0.0.2 10.0.0.100;
      }
    '';
    interfaces = [ "br0" ];
  };

  services.openssh.settings.PermitRootLogin = "yes";
}
