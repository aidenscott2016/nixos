{ ... }:
{
  flake.modules.nixos.flatpak =
    { lib, pkgs, config, ... }:
    {
      services.flatpak.enable = true;

      environment.pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
    };
}
