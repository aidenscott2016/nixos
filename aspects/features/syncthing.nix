{ lib, ... }:
{
  flake.nixosModules.syncthing = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.syncthing;
    in {
      options.aiden.modules.syncthing.enable = mkEnableOption "syncthing";

      config = mkIf cfg.enable {
        users.users.syncthing.extraGroups = [ "video" ];
        users.users.aiden.extraGroups = [ "syncthing" ];
        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
        };
      };
    };
}
