{ config, lib, pkgs, ... }:
with lib;
with lib.aiden; {
  options.aiden.modules.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf config.aiden.modules.desktop.enable {
    programs.nm-applet.enable = true;
    services = {
      xserver.enable = true;
      envfs.enable = true;
      blueman.enable = true;
      physlock = {
        muteKernelMessages = true;
        enable = true;
        lockOn.suspend = true;
      };
      tailscale.enable = true;
      mullvad-vpn.enable = true;
      gvfs.enable = true;
      libinput.enable = true;
      fstrim.enable = true;
    };
    security.sudo.wheelNeedsPassword = false;

    networking = { networkmanager.enable = true; };

    aiden.modules = {
      redshift = enabled;
      darkman = enabled;
      printer = enabled;
      emacs = enabled;
      thunar = enabled;
      locale = enabled;
      keyd = enabled;
      powermanagement = enabled;
      yubikey = enabled;
      flatpak = enabled;
      appimage = enabled;
      pipewire = enabled;
      ssh = enabled;
      avahi = enabled;
      common = enabled;
      multimedia = enabled;
      hardware-acceleration = enabled;
      ios = enabled;
      cli-base = enabled;
      xdg-portal = enabled;
    };

    hardware.bluetooth.enable = true;
  };
}
