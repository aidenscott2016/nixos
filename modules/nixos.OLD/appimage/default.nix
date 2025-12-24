{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.aiden.modules.appimage;
in
{
  options.aiden.modules.appimage = {
    enable = mkEnableOption "appimage";
  };

  config = mkIf cfg.enable {
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
