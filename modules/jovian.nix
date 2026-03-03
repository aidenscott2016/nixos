{ ... }:
{
  flake.modules.nixos.jovian =
    { lib, pkgs, config, ... }:
    with lib;
    {
      services.desktopManager.plasma6.enable = true;
    };
}
