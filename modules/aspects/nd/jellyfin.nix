{ nd, ... }: {
  nd.jellyfin = {
    includes = [
      nd.hardware-acceleration
    ];

    nixos =
{ pkgs, lib, config, ... }:
with lib;
with lib.options;
let
  cfg = config.narrowdivergent.aspects.jellyfin;
  driver = "iHD";
in
{

  options.narrowdivergent.aspects.jellyfin = {
    user = mkOption {
      type = types.str;
      default = "jellyfin";
    };
  };
  config = {
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
    systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = driver;
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = driver;
    };

  };
}
;
  };
}
