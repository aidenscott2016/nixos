{ lib, ... }:
{
  flake.modules.nixos.home-manager = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.home-manager;
    in {
      options.aiden.modules.home-manager.enable = mkEnableOption "home-manager integration";

      config = mkIf cfg.enable {
        # Use global packages
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        # Configure home-manager for the user
        home-manager.users.aiden = { };
      };
    };
}
