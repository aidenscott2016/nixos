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

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];
  };
  };

  aiden.modules.common.enabled = true;
  aiden.modules.cli-base.enabled = true;
  aiden.modules.locale.enabled = true;

  services.httpd.enable = true;
  services.httpd.adminAddr = "foo@example.org";

  services.k3s = {enable = true; extraFlags = ["--server k3s-microvm-2.sw1a1aa.uk"];};
  networking.firewall.allowedTCPPorts = [ 80 6443 ];

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "24.04";
}
