{ lib, ... }:
{
  flake.nixosModules.desktop = { config, lib, pkgs, ... }:
    with lib.aiden;
    with lib;
    let cfg = config.aiden.modules.desktop;
    in {
      options.aiden.modules.desktop = {
        enable = mkEnableOption "Enable desktop configuration";
        powermanagement.enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable power management";
        };
      };

      config = mkIf cfg.enable {
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

        aiden.modules = {
          syncthing = enabled;
          redshift = enabled;
          darkman = enabled;
          printer = enabled;
          emacs = enabled;
          thunar = enabled;
          locale = enabled;
          keyd = enabled;
          powermanagement.enable = cfg.powermanagement.enable;
          yubikey = enabled;

          # flatpak = enabled;        # breaks darkman due to xdg portal
          appimage = enabled;
          pipewire = enabled;
          ssh = enabled;
          avahi = enabled;
          common = enabled;
          multimedia = enabled;
          hardware-acceleration = enabled;
          ios = enabled;
          cli-base = enabled;
          #xdg-portal = enabled;
        };

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
    };
}
