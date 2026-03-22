{ inputs, ... }:
{
  flake.modules.nixos.jovian =
    { lib, pkgs, config, ... }:
    {
      imports = [ inputs.jovian.nixosModules.default ];

      jovian = {
        hardware = {
          has.amd.gpu = true;
          amd.gpu.enableBacklightControl = false;
        };
        steam = {
          updater.splash = "vendor";
          enable = true;
          autoStart = true;
          user = "aiden";
          desktopSession = "plasma";
        };
        steamos = {
          enableBluetoothConfig = false;
          useSteamOSConfig = true;
        };
      };

      services.desktopManager.plasma6.enable = true;
    };
}
