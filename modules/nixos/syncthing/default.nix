params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "syncthing";
  cfg = config.aiden.modules.${moduleName};
in
{
  options = {
    aiden.modules.${moduleName}.enabled = mkEnableOption moduleName;
  };
  config = mkIf cfg.enabled {

    users.users.syncthing.extraGroups = [ "video" ];
    users.users.aiden.extraGroups = [ "syncthing" ];
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };

}
