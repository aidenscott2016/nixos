{ config, lib, pkgs, ... }:
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
    };
    security.sudo.wheelNeedsPassword = false;

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
      hardware-acceleration.enable = true;
      ios = enabled;
      cli-base = enabled;
    };

    hardware.bluetooth.enable = true;
  };
}
