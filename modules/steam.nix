{ inputs, ... }:
{
  flake.modules.nixos.steam =
    { pkgs, lib, config, ... }:
    let
      steamtinkerlaunch-git = pkgs.steamtinkerlaunch.overrideAttrs (_: {
        src = inputs.steamtinkerlaunch;
      });
    in
    {
      config = {
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };
        programs.steam = {
          enable = true;
          protontricks.enable = true;
          extraCompatPackages = [ steamtinkerlaunch-git ];
        };
        environment.systemPackages = [
          steamtinkerlaunch-git
        ];

        programs.gamemode.enable = true;
        programs.gamemode.enableRenice = true;
        programs.gamemode.settings = {
          general.renice = 10;
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
        users.users.aiden.extraGroups = [ "gamemode" ];
      };
    };
}
