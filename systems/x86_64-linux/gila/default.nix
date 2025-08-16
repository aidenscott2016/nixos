{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    #./pxe.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    #./monitoring.nix
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.switch-fix.nixosModules.switch-fix
  ];

  age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
  age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
  age.secrets.gila-tailscale-authkey.file = "${inputs.self.outPath}/secrets/gila-tailscale-authkey";

  networking.hostName = "gila";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    tcpdump
    dnsutils
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [ "copytoram" ];
  boot.supportedFilesystems = pkgs.lib.mkForce [
    "btrfs"
    "vfat"
    "xfs"
    "ntfs"
    "cifs"
  ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  system.stateVersion = lib.mkForce "23.05";
  powerManagement.cpuFreqGovernor = "ondemand";
  services.irqbalance.enable = true;
  services.acpid.enable = true;

  aiden.modules = {
    powermanagement.enable = true;
    traefik.enable = true;
    tailscale = {
      enable = true;
      advertiseRoutes = true;
      authKeyPath = config.age.secrets.gila-tailscale-authkey.path;
    };
    avahi.enable = true;
    common = {
      email = "aiden@oldstreetjournal.co.uk";
      domainName = "sw1a1aa.uk";
      enable = true;
    };
    locale.enable = true;
    adguard.enable = true;
    home-assistant = {
      enable = true;
      devices = [
        "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
      ];
    };
    router.enable = true;
    router = {
      dns.enable = false; # TODO: remove
      dnsmasq.enable = true;
      internalInterface = "enp2s0";
      externalInterface = "enp1s0";
    };
  };

  systemd.network.wait-online.enable = false;

  services.iperf3.enable = true;
}
