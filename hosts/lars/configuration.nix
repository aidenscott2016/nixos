# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common/packages.nix ];
  nix.settings.auto-optimise-store = true;
  networking.firewall = {
    logRefusedConnections = true;
    enable = true;

    # xdebug. I want to narrow this down to  just the docker interface but the veth changes every time
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

  location.provider = "geoclue2";
  services =
    {
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
          windowManager.i3.enable = true;
          layout = "gb";
          xkbOptions = "caps:swapescape";
          libinput.enable = true;
        };

      printing.enable = true;
      printing.drivers = [ pkgs.hplip ];
      pcscd.enable = true;

    };


  security.rtkit.enable = true;

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
    };
  };

  users.users.aiden = {
    initialPassword = "password";
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "docker" ];
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
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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

  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        src = builtins.fetchGit https://github.com/aidenscott2016/dwm;
      });
    })
  ];



}

