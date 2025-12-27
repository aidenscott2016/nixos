{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = {
    # Use global packages
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # Configure home-manager for the user
    home-manager.users.aiden = { };
  };
}
