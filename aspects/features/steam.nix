{ lib, ... }:
{
  flake.modules.nixos.steam = { config, lib, pkgs, inputs, ... }:
    with lib;
    let
      cfg = config.aiden.modules.steam;
      steamtinkerlaunch-git = pkgs.steamtinkerlaunch.overrideAttrs (_: {
        src = inputs.steamtinkerlaunch;
      });
    in {
      options.aiden.modules.steam.enable = mkEnableOption "steam gaming platform";

      config = mkIf cfg.enable {
        # programs.gamescope.capSysNice = true;
        # work around for issue with capSysNice not working in gamescope.  even though it still
        # complains that it doesn't have cap nice ability to set it its own nice value.  ananicy
        # is setting it -20 (highest priority).  this could probably go into its own config since
        # ananicy-rules-cachyos has quality of life rules for a lot more then just gamescope.
        # and games.
        services.ananicy = with pkgs; {
          enable = true;
          package = ananicy-cpp;
          rulesProvider = ananicy-rules-cachyos;
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
        environment.systemPackages = [
          steamtinkerlaunch-git
        ];

        # game mode module
        programs.gamemode.enable = true;
        programs.gamemode.enableRenice = true;
        programs.gamemode.settings = {
          general = {
            renice = 10;
          };

          # Warning: GPU optimisations have the potential to damage hardware
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
        users.users.aiden.extraGroups = [ "gamemode" ];
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };

        # Override the default gamescope session package to use a wrapper with proper D-Bus initialization
        # Fixes immediate crash when launching Steam session from greeter
        # See: https://github.com/nixos/nixpkgs/issues/419121
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
    };
}
