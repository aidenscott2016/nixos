{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.aiden.modules.appimage;
in {
  options.aiden.modules.appimage = {
    enabled = mkEnableOption "appimage";
  };

  config = mkIf cfg.enabled {
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