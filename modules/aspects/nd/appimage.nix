{ nd, ... }: {
  nd.appimage = {
    nixos =
{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = {
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
;
  };
}
