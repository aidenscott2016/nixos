{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { lib, pkgs, config, ... }:
    with lib;
    with pkgs;
    let
      cfg = config.aiden.modules.gaming;
      minecraftPackages = optionals cfg.games.minecraft.enable [ prismlauncher ];
      moonlightClient = optionals cfg.moonlight.client.enable [ moonlight-qt ];
    in
    {
      imports = with inputs.self.modules.nixos; [
        steam
        oblivion-sync
        openttd
      ];

      options.aiden.modules.gaming = {
        steam.enable = mkEnableOption "steam";
        moonlight = {
          server.enable = mkEnableOption "moonlight server";
          client.enable = mkEnableOption "moonlight client";
        };
        games = {
          oblivionSync.enable = mkEnableOption "oblivion sync";
          openttd.enable = mkEnableOption "openttd";
          minecraft.enable = mkEnableOption "minecraft";
        };
      };

      config = {
        services.sunshine = mkIf cfg.moonlight.server.enable {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
        };
        aiden.modules.steam.enable = cfg.steam.enable;
        aiden.modules.oblivionSync.enable = cfg.games.oblivionSync.enable;
        aiden.programs.openttd.enable = cfg.games.openttd.enable;
        environment.systemPackages = minecraftPackages ++ moonlightClient;
        # boot.kernelParams = [ "preempt=full" ]; # re-enable if audio latency or gaming input lag is noticed
      };
    };
}
