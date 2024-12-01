{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.microvm.nixosModules.microvm ];

  microvm = {
    interfaces = [{
      type = "tap";
      id = "vm-k3s";
      mac = "02:00:00:00:00:01";
    }];
    shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }];
  };
  systemd.network.enable = true;

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = { DHCP = "yes"; };
  };

  aiden.modules.common.enabled = true;
  aiden.modules.cli-base.enabled = true;
  aiden.modules.locale.enabled = true;


  services.httpd.enable = true;
  services.httpd.adminAddr = "foo@example.org";

  networking.firewall.allowedTCPPorts = [ 80];
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "24.04";
}
