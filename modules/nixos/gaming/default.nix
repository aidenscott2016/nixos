_@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with pkgs;
let
  moduleName = "gaming";
  cfg = config.aiden.modules.${moduleName};
  minecraftPackages = optionals cfg.games.minecraft.enable [
    # minecraft -- broken package
    prismlauncher
  ];
  moonlightClient = optionals cfg.moonlight.client.enable [ moonlight-qt ];

in
{
  options = {
    aiden.modules."${moduleName}" = {
      steam.enable = mkEnableOption moduleName;
      moonlight = {
        server.enable = mkEnableOption "enable moonlight server";
        client.enable = mkEnableOption "enable moonlight client";
      };
      games = {
        openttd.enable = mkEnableOption "enable openttd game";
        minecraft.enable = mkEnableOption "enable minecraft game";
      };
    };
  };
  config = {
    aiden.modules = {
      steam.enable = cfg.steam.enable;
    };
    aiden.programs = {
      openttd.enable = cfg.games.openttd.enable;
    };
    environment.systemPackages = minecraftPackages ++ moonlightClient;

    boot.kernelParams = [
      "preempt=full" # may help with audio stuttering in proton games
    ];
  };
}
