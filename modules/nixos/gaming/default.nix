_@{ lib, pkgs, config, ... }:
with lib;
with pkgs;
let
  moduleName = "gaming";
  cfg = config.aiden.modules.${moduleName};
  minecraftPackages = optionals cfg.games.minecraft.enabled [
    # minecraft -- broken package
    prismlauncher
  ];
  moonlightClient = optionals cfg.moonlight.client.enabled [ moonlight-qt ];

in {
  options = {
    aiden.modules."${moduleName}" = {
      steam.enabled = mkEnableOption moduleName;
      moonlight = {
        server.enabled = mkEnableOption "enable moonlight server";
        client.enabled = mkEnableOption "enable moonlight client";
      };
      games = {
        openttd.enabled = mkEnableOption "enable openttd game";
        minecraft.enabled = mkEnableOption "enable minecraft game";
      };
    };
  };
  config = {
    aiden.modules = { steam.enabled = cfg.steam.enabled; };
    aiden.programs = { openttd.enabled = cfg.games.openttd.enabled; };
    environment.systemPackages = minecraftPackages ++ moonlightClient;
  };
}
