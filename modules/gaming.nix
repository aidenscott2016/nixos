{ ... }:
{
  flake.modules.nixos.gaming =
    { lib, pkgs, config, ... }:
    with lib;
    let
      cfg = config.aiden.modules.gaming;
      minecraftPackages = optionals cfg.games.minecraft.enable [ pkgs.prismlauncher ];
      moonlightClient = optionals cfg.moonlight.client.enable [ pkgs.moonlight-qt ];
    in
    {
      options.aiden.modules.gaming = {
        moonlight = {
          server.enable = mkEnableOption "moonlight server";
          client.enable = mkEnableOption "moonlight client";
        };
        games = {
          minecraft.enable = mkEnableOption "minecraft";
        };
      };

      config = {
        services.sunshine = mkIf cfg.moonlight.server.enable {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
        };
        environment.systemPackages = minecraftPackages ++ moonlightClient;
        # boot.kernelParams = [ "preempt=full" ]; # re-enable if audio latency or gaming input lag is noticed
      };
    };
}
