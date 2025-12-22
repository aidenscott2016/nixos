{ lib, ... }:
{
  flake.modules.nixos.jovian = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.jovian;
    in {
      options.aiden.modules.jovian.enable = mkEnableOption "jovian steam deck support";

      config = mkIf cfg.enable {
        services.desktopManager.plasma6.enable = true;
        # jovian = {
        #   hardware = {
        #     has.amd.gpu = true;
        #     amd.gpu.enableBacklightControl = false;
        #   };
        #   steam = {
        #     updater.splash = "vendor";
        #     enable = true;
        #     autoStart = true;
        #     user = "aiden";
        #     desktopSession = "plasma";
        #   };
        #   steamos = {
        #     useSteamOSConfig = true;
        #   };
        # };
      };
    };
}
