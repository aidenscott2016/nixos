{ lib, pkgs, config, inputs, ... }:
{
  #  imports = [ inputs.jovian.nixosModules.default ];
  config = {
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
}
