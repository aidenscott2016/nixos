params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.options;
let
  cfg = config.aiden.modules.jellyfin;
in
{
  options.aiden.modules.jellyfin = {
    enable = mkEnableOption "";
    user = mkOption {
      type = types.str;
      default = "jellyfin";
    };
  };
  config = mkIf cfg.enable {
    aiden.modules.hardware-acceleration.enable = true;
    users.users.jellyfin.extraGroups = [ "video" ];
    environment.systemPackages = with pkgs; [
      rename
      jellyfin-ffmpeg
      libva-utils
    ];
    services = {
      jellyfin = {
        user = cfg.user;
        group = "render";
        enable = true;
        openFirewall = false;
      };
    };

  };
}
