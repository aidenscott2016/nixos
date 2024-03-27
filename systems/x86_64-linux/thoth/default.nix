# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, modulesPath, ... }:


with inputs; {
  imports = [
    ./hardware-configuration.nix
    disko.nixosModules.disko
    ./disk-config.nix
    agenix.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  age.secrets.thoth-tailscale-authkey.file = "${self.outPath}/secrets/thoth-tailscale-authkey";
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  security.sudo.wheelNeedsPassword = false;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [
      53
      config.services.adguardhome.settings.bind_port
    ];
  };

  environment.systemPackages = with pkgs; [ dnsutils tailscale ];


  aiden = {
    modules = {
      tailscale = {
        enabled = true;
        authKeyPath = config.age.secrets.thoth-tailscale-authkey.path;
      };
      avahi.enabled = true;
      common.enabled = true;
    };
  };

  services = {
    adguardhome = {
      enable = true;
      openFirewall = false;
      settings.bind_host = "0.0.0.0";
      settings.bind_port = 8081;
      querylog.enabled = false;
    };
  };
  system.stateVersion = "23.05"; # Did you read the comment?

}

