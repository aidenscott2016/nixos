{ inputs, ... }:
{
  flake.modules.nixos.jellyfin =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.modules.jellyfin;
      driver = "iHD";
    in
    {
      imports = with inputs.self.modules.nixos; [
        hardware-acceleration
      ];
      options.aiden.modules.jellyfin = {
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
    };
}
