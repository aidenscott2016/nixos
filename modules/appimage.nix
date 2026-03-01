{ ... }:
{
  flake.modules.nixos.appimage =
    { lib, pkgs, config, ... }:
    with lib;
    {
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      environment.systemPackages = with pkgs; [
        appimage-run
      ];

      environment.pathsToLink = [
        "/share/applications"
      ];
    };
}
