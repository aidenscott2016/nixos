{ aiden, ... }:
{
  aiden.gaming.nixos =
    { pkgs, config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.gaming or { };
    in
    {
      options.aiden.aspects.gaming = {
        steam.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Steam";
        };
        moonlight = {
          client.enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Moonlight game streaming client";
          };
          server.enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Sunshine game streaming server";
          };
        };
        oblivionSync.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable Oblivion save syncing via Syncthing";
        };
      };

      config = mkMerge [
        {
          boot.kernelParams = [ "preempt=full" ];
        }

        (mkIf (cfg.moonlight.client.enable or false) {
          environment.systemPackages = with pkgs; [ moonlight-qt ];
        })

        (mkIf (cfg.moonlight.server.enable or false) {
          services.sunshine = {
            enable = true;
            openFirewall = true;
            capSysAdmin = true;
          };
        })
      ];
    };

  # Note: This aspect provides configuration options but delegates actual
  # functionality to specific aspects:
  # - aiden.steam for Steam support
  # - aiden.oblivion-sync for save game syncing
  # These should be included separately when gaming.steam.enable or
  # gaming.oblivionSync.enable are true.
}
