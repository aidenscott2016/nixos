{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ../syncthing/default.nix
    ../redshift/default.nix
    ../darkman/default.nix
    ../printer/default.nix
    ../emacs/default.nix
    ../thunar/default.nix
    ../locale/default.nix
    ../keyd/default.nix
    ../powermanagement/default.nix
    ../yubikey/default.nix
    ../appimage/default.nix
    ../pipewire/default.nix
    ../ssh/default.nix
    ../avahi/default.nix
    ../common/default.nix
    ../multimedia/default.nix
    ../hardware-acceleration/default.nix
    ../ios/default.nix
    ../cli-base/default.nix
  ];

  options.aiden.modules.desktop = {
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

    aiden.modules.powermanagement.enable = config.aiden.modules.desktop.powermanagement.enable;

    # flatpak breaks darkman due to xdg portal
    # aiden.modules.xdg-portal.enable = false;

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
