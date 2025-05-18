params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "home-manager";
in
{
  options = {
    aiden.modules.home-manager.enable = mkEnableOption moduleName;
  };

  config = mkIf config.aiden.modules.home-manager.enable {
    # Use global packages
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # Configure home-manager for the user
    home-manager.users.aiden = { };
  };
}
