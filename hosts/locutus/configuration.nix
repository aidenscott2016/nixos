{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ../../modules/ios.nix
    ./autorandr
    ../../modules/redshift.nix
    ../../modules/printer.nix
    ../../modules/ssh.nix
    ./disko.nix
  ];

  networking.firewall = {
    logRefusedConnections = true;
    enable = true;
    # xdebug. I want to narrow this down to just the docker interface but the veth changes every time
    allowedTCPPorts = [ 9000 ];
    allowedUDPPorts = [ 9000 ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "locutus";
  networking.networkmanager.enable = true;



  services =
    {
      fstrim.enable = true;
      #this is enabled by hardware-support. It is unecessary since
      #there is an SSD
      hdapsd.enable = false;
      upower.enable = true;
      auto-cpufreq.enable = true;


    };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  programs.nm-applet.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };


  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };


  services.gvfs.enable = true;



  services.picom = {
    enable = true;
    vSync = true;
  };

}

