# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common/packages.nix ];
  nix.settings.auto-optimise-store = true;
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
      autorandr = {
        enable = true;
        defaultTarget = "mobile";
        profiles =
          let
            fingerprint = {
              DP2 = "00ffffffffffff0010acfcd0535744301a1e0104a53c22783a9325a9544d9e250c5054a54b008100b300d100714fa9408180d1c00101565e00a0a0a029503020350055502100001a000000ff0033515a475430330a2020202020000000fc0044454c4c20503237323044430a000000fd00314b1d711c010a20202020202001f8020314b14f90050403020716010611121513141f023a801871382d40582c450055502100001e011d8018711c1620582c250055502100009e7e3900a080381f4030203a0055502100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2";
              LVDS-1 = "00ffffffffffff0030e4d8020000000000160103801c1078ea8855995b558f261d505400000001010101010101010101010101010101601d56d85000183030404700159c1000001b000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503132355748322d534c42330059";
            };
          in
          {
            docked = {
              inherit fingerprint;
              config = { LVDS-1.enable = false; DP-2.enable = true; };
            };
            mobile = {
              inherit fingerprint;
              config = { LVDS-1.enable = true; DP-2.enable = false; LVDS-1.mode = "1366x768"; };
            };
          };
      };
      avahi.enable = true;
      avahi.nssmdns = true;

      geoclue2.enable = true;
      redshift = {
        enable = true;
      };
      usbmuxd.enable = true;
      xserver =
        {
          enable = true;
          windowManager.dwm.enable = true;
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

  users.users.aiden = {
    initialPassword = "password";
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "docker" "cheese" ];
  };
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;
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


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

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

  nix.extraOptions = "experimental-features = nix-command flakes";
  environment.sessionVariables = rec {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    AWT_TOOLKIT = "MToolkit";
  };
  environment.etc = {
    "fuse.conf" = {
      text =
        ''
          user_allow_other
        '';
    };
  };
}

