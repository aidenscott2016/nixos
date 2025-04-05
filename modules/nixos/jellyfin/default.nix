params@{ pkgs, lib, config, ... }:
with lib;
with lib.options;
let
  cfg = config.aiden.modules.jellyfin;
  accelOptions = with pkgs;{
    intel = [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      intel-compute-runtime

    ];
    amd = [ mesa amdvlk libva ];
  };
in
{
  options.aiden.modules.jellyfin = {
    enable = mkEnableOption "";
    user = mkOption {
      type = types.str;
      default = "jellyfin";
    };
    hwAccel = {
      enable = mkEnableOption "";
      arch = mkOption {
        type = types.enum [ "intel" "amd" ];
      };
    };
  };
  config = mkIf cfg.enable {
    users.users.jellyfin.extraGroups = ["video"];
    environment.systemPackages = with pkgs; [ rename jellyfin-ffmpeg libva-utils ];
    services = {
      jellyfin = {
        user = cfg.user;
        group = "render";
        enable = true;
        openFirewall = false;
      };
    };

    hardware.graphics = mkIf cfg.hwAccel.enable {
      enable = true;
      extraPackages = accelOptions.${cfg.hwAccel.arch};
    };
    boot.kernelParams = mkIf (cfg.hwAccel.enable && cfg.hwAccel.arch == "intel") [
      "i915.enable_guc=2"
    ];

  };
}
