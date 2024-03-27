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
    enabled = mkEnableOption "";
    user = mkOption {
      type = types.str;
      default = "jellyfin";
    };
    hwAccel = {
      enabled = mkEnableOption "";
      arch = mkOption {
        type = types.enum [ "intel" "amd" ];
      };
    };
  };
  config = mkIf cfg.enabled {
    environment.systemPackages = with pkgs; [ rename jellyfin-ffmpeg libva-utils ];
    services = {
      jellyfin = {
        user = cfg.user;
        group = "render";
        enable = true;
        openFirewall = true;
      };
    };

    hardware.opengl = mkIf cfg.hwAccel.enabled {
      enable = true;
      extraPackages = accelOptions.${cfg.hwAccel.arch};
      driSupport = true;
    };
    boot.kernelParams = mkIf (cfg.hwAccel.enabled && cfg.hwAccel.arch == "intel") [
      "i915.enable_guc=2"
    ];

  };
}
