{ nd, ... }: {
  nd.gaming = {
    nixos =
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "gaming";
  cfg = config.narrowdivergent.aspects.${moduleName};
in
{
  imports = [
    ../steam/default.nix
    ../oblivion-sync/default.nix
    ../openttd/default.nix
  ];

  options = {
    narrowdivergent.aspects."${moduleName}" = {
      steam.enable = mkEnableOption moduleName;
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
  };
  config = {
    services.sunshine = mkIf cfg.moonlight.server.enable {
      enable = true;
      openFirewall = true;
      capSysAdmin = true;
    };
    narrowdivergent.modules = {
      steam.enable = cfg.steam.enable;
      oblivionSync.enable = cfg.games.oblivionSync.enable;
    };
    narrowdivergent.programs = {
      openttd.enable = cfg.games.openttd.enable;
    };
    environment.systemPackages =
      optionals cfg.games.minecraft.enable [
        # minecraft -- broken package
        pkgs.prismlauncher
      ]
      ++ optionals cfg.moonlight.client.enable [ pkgs.moonlight-qt ];

    boot.kernelParams = [
      "preempt=full" # may help with audio stuttering in proton games
    ];
  };
}
;
  };
}
