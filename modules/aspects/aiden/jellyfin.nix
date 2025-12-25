{ aiden, ... }:
{
  aiden.jellyfin = {
    includes = [
      aiden.hardware-acceleration
    ];

    nixos =
      { pkgs, lib, config, ... }:
      with lib;
      let
        cfg = config.aiden.aspects.jellyfin or { };
        driver = "iHD";
      in
      {
        options.aiden.aspects.jellyfin = {
          enable = mkEnableOption "Jellyfin media server";
          user = mkOption {
            type = types.str;
            default = "jellyfin";
          };
        };

        config = mkIf (cfg.enable or false) {
          users.users.jellyfin.extraGroups = [ "video" ];
          environment.systemPackages = with pkgs; [
            rename
            jellyfin-ffmpeg
            libva-utils
          ];
          services.jellyfin = {
            user = cfg.user;
            group = "render";
            enable = true;
            openFirewall = false;
          };
          systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = driver;
          environment.sessionVariables = {
            LIBVA_DRIVER_NAME = driver;
          };
        };
      };
  };
}
