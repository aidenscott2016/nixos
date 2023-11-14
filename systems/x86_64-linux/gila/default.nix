{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    ./disko-config.nix
  ];

  networking.hostName = "gila";
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;
  networking.usePredictableInterfaceNames = true;
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
    common.enabled = true;
    router = {
      enabled = true;
      internalInterface = "eth1";
      externalInterface = "eth0";
    };
  };
}
