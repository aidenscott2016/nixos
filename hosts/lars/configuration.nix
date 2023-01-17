{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common/packages.nix ../../modules/ios.nix ./autorandr ];

  networking.firewall = {
    logRefusedConnections = true;
    enable = true;
    # xdebug. I want to narrow this down to just the docker interface but the veth changes every time
    allowedTCPPorts = [ 9000 ];
    allowedUDPPorts = [ 9000 ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lars";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  location.provider = "geoclue2"; # for Redshift
  services =
    {
      fstrim.enable = true;
      #this is enabled by hardware-support. It is unecessary since
      #there is an SSD
      hdapsd.enable = false;
      upower.enable = true;
      auto-cpufreq.enable = true;
      avahi.enable = true;
      avahi.nssmdns = true;

      #redshift
      geoclue2.enable = true;
      redshift = {
        enable = true;
      };
      xserver =
        {
          enable = true;
          layout = "gb";
          xkbOptions = "caps:swapescape";
          libinput.enable = true;
        };

      printing.enable = true;
      printing.drivers = [ pkgs.hplip ];
      pcscd.enable = true;

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
      device = "/dev/disk/by-uuid/e754208b-f961-48f3-8f00-dc636f3c646d";
      preLVM = true;
    };
    home = {
      device = "/dev/disk/by-label/870-evo";
      preLVM = true;
    };
  };

  # could be moved to DWM
  environment.sessionVariables = rec {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    AWT_TOOLKIT = "MToolkit";
  };

  services.gvfs.enable = true;
}

