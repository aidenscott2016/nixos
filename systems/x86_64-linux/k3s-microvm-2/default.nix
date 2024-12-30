{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.microvm.nixosModules.microvm ];

  microvm = {
    mem = 4 * 1024;
    vcpu = 4;
    interfaces = [{
      type = "tap";
      id = "vm-k3s";
      mac = "02:00:00:00:00:01";
    }];
    volumes = [{
      mountPoint = "/";
      image = "root.img";
      size = 10 * 1024;
    }];
    shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }];
  };

  aiden.modules.common.enabled = true;
  aiden.modules.cli-base.enabled = true;
  aiden.modules.locale.enabled = true;

  services.k3s = {
    enable = true;
    extraFlags =
      [ "--tls-san k3s-microvm-2.sw1a1aa.uk" "--write-kubeconfig-mode 644" ];
  };
  networking.firewall.allowedTCPPorts = [ 80 6443 ];

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "24.04";
}
