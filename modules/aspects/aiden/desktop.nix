{ aiden, ... }:
{
  # Desktop meta-aspect that includes common desktop functionality
  # Hosts can include this aspect to get a full desktop environment

  aiden.desktop = {
    includes = [
      aiden.syncthing
      aiden.redshift
      aiden.darkman
      aiden.printer
      aiden.thunar
      aiden.keyd
      aiden.powermanagement
      aiden.yubikey
      aiden.appimage
      aiden.pipewire
      aiden.ssh
      aiden.avahi
      aiden.common
      aiden.multimedia
      aiden.hardware-acceleration
      aiden.ios
      aiden.cli-base
      aiden.emacs
    ];

    nixos =
      { pkgs, config, lib, ... }:
      with lib;
      let
        cfg = config.aiden.aspects.desktop or { };
      in
      {
        options.aiden.aspects.desktop = {
          powermanagement.enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable power management";
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

          networking.networkmanager.enable = true;

          systemd.network.wait-online.enable = false;

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
  };
}
