{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { lib, pkgs, config, ... }:
    with lib;
    {
      imports = with inputs.self.modules.nixos; [
        common architecture
        syncthing redshift darkman printer emacs thunar
        locale keyd yubikey appimage pipewire ssh avahi
        multimedia hardware-acceleration ios cli-base
        powermanagement xdg-portal beets
      ];

      options.aiden.modules.desktop.powermanagement.enable = mkOption {
        type = types.bool;
        default = true;
      };

      config = {
        aiden.modules.powermanagement.enable =
          config.aiden.modules.desktop.powermanagement.enable;

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
          bindfs xorg.xev
          (discord.override { withTTS = false; })
          cameractrls-gtk3 chromium xclip libreoffice
          kdePackages.okular vscode nodejs_22 claude-code
        ];
      };
    };

  flake.modules.homeManager.desktop =
    { config, pkgs, lib, ... }:
    {
      home.stateVersion = "23.05";
      xdg.enable = true;
      home.file."downloads".source = config.lib.file.mkOutOfStoreSymlink "/home/aiden/Downloads";
    };
}
