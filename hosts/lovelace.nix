{ config, lib, pkgs, ... }:

{
  system.stateVersion = "22.05";
  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "lovelace";
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.firewall.enable = false;
  environment.systemPackages = with pkgs; [ dnsutils ];
  networking.usePredictableInterfaceNames = true;
  boot.kernel.sysctl = { "net.ipv4.conf.all.forwarding" = true; };
  # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1008362877
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  specialisation = {
    pihole.configuration.virtualisation.oci-containers = {
      backend = "podman";
      containers.pihole = {
        volumes = [ "etc-pihole:/etc/pihole" "etc-dnsmasq:/etc/dnsmasq.d" ];
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "67:67/udp" # Only required if you are using Pi-hole as your DHCP server
          "80:80/tcp"
        ];
        environment.TZ = "Europe/London";
        image = "pihole/pihole:latest";
        extraOptions = [ "--network=host" ];
      };
    };
    adguard-home.configuration = { };
  };

  # networking = {
  #   defaultGateway = {
  #     address = "192.168.0.1";
  #     interface = "eth0";
  #   };
  #   interfaces.eth0 = { };

  #   interfaces.br0 = {
  #     ipv4.addresses = [{
  #       address = "10.0.0.1";
  #       prefixLength = 24;
  #     }];
  #   };

  #   interfaces.eth3 = {
  #     useDHCP = true;
  #     ipv4.addresses = [{
  #       address = "192.168.1.2";
  #       prefixLength = 24;
  #     }];
  #   };

  #   bridges.br0 = { interfaces = [ "eth1" "eth2" ]; };

  #   nat.enable = true;
  #   nat.externalInterface = "eth0";
  #   nat.internalInterfaces = [ "br0" ];
  # };

  # services.dhcpd4 = {
  #   enable = true;
  #   extraConfig = ''
  #     option subnet-mask 255.255.255.0;
  #     option routers 10.0.0.1;
  #     option domain-name-servers 10.0.0.1, 9.9.9.9;
  #     subnet 10.0.0.1 netmask 255.255.255.0 {
  #         range 10.0.0.2 10.0.0.100;
  #     }
  #   '';
  #   interfaces = [ "br0" ];
  # };

}
