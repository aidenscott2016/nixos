{ lib, ... }:
{
  flake.nixosModules.gaming = { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.modules.gaming;
      minecraftPackages = optionals cfg.games.minecraft.enable [
        # minecraft -- broken package
        pkgs.prismlauncher
      ];
      moonlightClient = optionals cfg.moonlight.client.enable [ pkgs.moonlight-qt ];
    in {
      options.aiden.modules.gaming = {
        steam.enable = mkEnableOption "enable steam";
        moonlight = {
          server.enable = mkEnableOption "enable moonlight server";
          client.enable = mkEnableOption "enable moonlight client";
        };
        games = {
          oblivionSync.enable = mkEnableOption "sync oblivion saves via syncthing";
          openttd.enable = mkEnableOption "enable openttd game";
          minecraft.enable = mkEnableOption "enable minecraft game";
        };
      };

      config = {
        services.sunshine = mkIf cfg.moonlight.server.enable {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
        };
        aiden.modules = {
          steam.enable = cfg.steam.enable;
          oblivionSync.enable = cfg.games.oblivionSync.enable;
        };
        aiden.programs = {
          openttd.enable = cfg.games.openttd.enable;
        };
        environment.systemPackages = minecraftPackages ++ moonlightClient;

        boot.kernelParams = [
          "preempt=full" # may help with audio stuttering in proton games
        ];
      };
    };
}
