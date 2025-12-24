{ inputs, ... }:
{
  aiden.steam.nixos =
    { pkgs, config, lib, ... }:
    let
      steamtinkerlaunch-git = pkgs.steamtinkerlaunch.overrideAttrs (_: {
        src = inputs.steamtinkerlaunch;
      });
    in
    {
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      programs.gamescope.env = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      programs.steam = {
        enable = true;
        protontricks.enable = true;
        gamescopeSession = {
          enable = true;
          steamArgs = [
            "-gamepadui"
            "-pipewire-dmabuf"
            "-steamdeck"
            "-steamos3"
            "-console"
          ];
        };
        extraCompatPackages = [ steamtinkerlaunch-git ];
      };

      environment.systemPackages = [ steamtinkerlaunch-git ];

      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general.renice = 10;
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            nv_powermizer_mode = 1;
          };
          custom = {
            start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };

      users.users.aiden.extraGroups = [ "gamemode" ];
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Override the default gamescope session package
      services.displayManager.sessionPackages =
        let
          steam-session =
            pkgs.runCommand "steam-session"
              {
                passthru.providedSessions = [ "steam" ];
              }
              ''
                mkdir -p $out/share/wayland-sessions
                cat > $out/share/wayland-sessions/steam.desktop <<EOF
                [Desktop Entry]
                Name=Steam (Gamescope)
                Comment=Steam Big Picture Mode in Gamescope compositor
                Exec=${pkgs.writeShellScriptBin "start-steam-gamescope" ''
                  #!${pkgs.bash}/bin/bash
                  set -e
                  export XDG_SESSION_TYPE="wayland"
                  export XDG_CURRENT_DESKTOP="gamescope"
                  if [[ -z "''${DBUS_SESSION_BUS_ADDRESS}" ]]; then
                    exec ${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.gamescope}/bin/gamescope --steam -- ${config.programs.steam.package}/bin/steam -tenfoot -pipewire-dmabuf
                  else
                    exec ${pkgs.gamescope}/bin/gamescope --steam -- ${config.programs.steam.package}/bin/steam -tenfoot -pipewire-dmabuf
                  fi
                ''}/bin/start-steam-gamescope
                Type=Application
                DesktopNames=gamescope
                EOF
              '';
        in
        lib.mkIf config.programs.steam.gamescopeSession.enable ([ steam-session ]);
    };
}
