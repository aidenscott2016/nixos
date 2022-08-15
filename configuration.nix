# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
with builtins; let
  pulse14 = import
    (fetchTarball {
      name = "pulse14";
      url = "https://github.com/NixOS/nixpkgs/archive/17dbf56cea00eb47fa77ab1efbce75faef4b505c.zip";
    })
    { };


in
{
  imports = [ ./hardware-configuration.nix ];

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


  #sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      package = pulse14.pulseaudioFull;
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
  environment.systemPackages = with pkgs; [
    pulse14.pulseaudioFull
    pgcli
    jetbrains.idea-community
    slock
    vim
    wget
    emacs
    git
    firefox
    arandr
    st
    pavucontrol
    spotify
    pass
    pinentry-gtk2
    nixpkgs-fmt
    tmux
    libimobiledevice
    ifuse
    tor-browser-bundle-bin
    scala
    sbt
    xorg.xbacklight
    metals
    monero-gui
    file
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  programs.nm-applet.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

