{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "gila";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;
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
    avahi.enabled = true;
    common.enabled = true;
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


  age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
  age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";

  networking.hosts."10.0.0.1" = [ "i.sw1a1aa.uk" ];

  services.nginx.enable = lib.mkForce false;


  users.users.traefik.extraGroups = [ "acme" ]; # to read acme folder
  services.traefik = {
    enable = true;
    group = "podman";
    staticConfigOptions = {
      accessLog = { };
      log.level = "DEBUG";
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
      providers.docker = {
        exposedByDefault = false;
        endpoint = "unix:///var/run/podman/podman.sock";
      };
      api.dashboard = true;
      api.insecure = true;
      entrypoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure.address = ":443";
      };
    };
    dynamicConfigOptions = {
      tls = {
        stores.default = {
          defaultCertificate = {
            certFile = "/var/lib/acme/sw1a1aa.uk/fullchain.pem";
            keyFile = "/var/lib/acme/sw1a1aa.uk/key.pem";
          };
        };
      };
    };
  };
}
