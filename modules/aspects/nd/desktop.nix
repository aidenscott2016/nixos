{ nd, ... }: {
  nd.desktop = {
    includes = [
      nd.syncthing
      nd.redshift
      nd.darkman
      nd.printer
      nd.emacs
      nd.thunar
      nd.locale
      nd.keyd
      nd.powermanagement
      nd.yubikey
      nd.appimage
      nd.pipewire
      nd.ssh
      nd.avahi
      nd.common
      nd.multimedia
      nd.hardware-acceleration
      nd.ios
      nd.cli-base
    ];

    nixos =
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{

  options.narrowdivergent.aspects.desktop = {
    powermanagement.enable = mkOption {
      type = lib.types.bool;
      default = true;
      description = "fuck you";
    };
  };

  config = {
    programs.nm-applet.enable = true;
    services = {
      xserver.enable = true;
      envfs.enable = true;
      blueman.enable = true;
      tailscale.enable = true;
      mullvad-vpn.enable = true;
      gvfs.enable = true;
      libinput.enable = true;
      fstrim.enable = true;
    };
    security.sudo.wheelNeedsPassword = false;

    networking = {
      networkmanager.enable = true;
    };

    systemd.network.wait-online.enable = false;

    narrowdivergent.aspects.powermanagement.enable = config.narrowdivergent.aspects.desktop.powermanagement.enable;

    # flatpak = enabled;        # breaks darkman due to xdg portal
    #xdg-portal = enabled;

    hardware.bluetooth.enable = true;
    environment.systemPackages = with pkgs; [
      bindfs
      xorg.xev

      (discord.override { withTTS = false; })
      cameractrls-gtk3
      chromium
      xclip
      libreoffice
      kdePackages.okular

      vscode
      nodejs_22
      claude-code
    ];

  };
}
;
  };
}
