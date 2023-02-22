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
    ../../modules/php-docker.nix
    ./disko.nix
  ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

  networking.hostName = "locutus";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;


  networking.firewall = {
    allowedTCPPorts = [
      24800 # barrier
    ];
    enable = true;
  };

  services =
    {
      fstrim.enable = true;
      #this is enabled by hardware-support. It is unecessary since
      #there is an SSD
      hdapsd.enable = false;
      upower.enable = true;
      auto-cpufreq.enable = true;
      xserver.enable = true;


    };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;


  # programs.gnupg.agent = {
  #   enable = true;
  #   pinentryFlavor = "gtk2";
  #   enableSSHSupport = true;
  # };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };




  services.gvfs.enable = true;


  # move this to dwm some time
  services.picom = {
    enable = true;
    vSync = true;
  };

  programs.light.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];
}

