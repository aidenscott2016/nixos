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
    aiden.modules.${moduleName}.enable = mkEnableOption moduleName;
  };
  config = mkIf cfg.enable {

    users.users.syncthing.extraGroups = [ "video" ];
    users.users.aiden.extraGroups = [ "syncthing" ];
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };

}
