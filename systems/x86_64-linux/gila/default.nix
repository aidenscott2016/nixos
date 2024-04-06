{ config, pkgs, inputs, lib, ... }: {
  imports = [
    #./pxe.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    ./monitoring.nix
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
  age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
  age.secrets.gila-tailscale-authkey.file = "${inputs.self.outPath}/secrets/gila-tailscale-authkey";

  networking.hostName = "gila";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;
  networking.hosts."10.0.0.1" = [ "gila.sw1a1aa.uk" "jellyfin.sw1a1aa.uk" ];

  environment.systemPackages = with pkgs; [ tcpdump dnsutils ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.conf.all.forwarding" = true; };
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [ "copytoram" ];
  boot.supportedFilesystems =
    pkgs.lib.mkForce [ "btrfs" "vfat" "xfs" "ntfs" "cifs" ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  system.stateVersion = lib.mkForce "23.05";
  powerManagement.cpuFreqGovernor = "ondemand";
  services.irqbalance.enable = true;
  services.acpid.enable = true;

  aiden.modules = {
    traefik.enabled = true;
    tailscale = {
      enabled = true;
      advertiseRoutes = true;
      authKeyPath = config.age.secrets.gila-tailscale-authkey.path;
    };
    avahi.enabled = true;
    common = {
      email = "aiden@oldstreetjournal.co.uk";
      domainName = "sw1a1aa.uk";
      enabled = true;
    };
    adguard.enabled = true;
    home-assistant = {
      enabled = true;
      devices = [
        "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
      ];
    };
    router.enabled = true;
    router = {
      dns.enabled = false; # TODO: remove
      dnsmasq.enabled = true;
      internalInterface = "eth1";
      externalInterface = "eth0";
    };
  };
}
