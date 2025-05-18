params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "oblivionSync";
  cfg = config.aiden.modules.${moduleName};
  obDataDir = cfg.obDataDir;
  stDataDir = cfg.stDataDir;
in
{
  options = {
    aiden.modules.${moduleName} = {
      stDataDir = mkOption {
        description = "target to mount oblivion from";
        type = types.path;
        default = "${config.services.syncthing.dataDir}/Oblivion";

      };
      obDataDir = mkOption {
        description = "path to mount oblivion";
        type = types.path;
        default = "/home/aiden/oblivion-sync";
      };
      enable = mkEnableOption moduleName;
    };

  };
  config = mkIf cfg.enable {
    aiden.modules = {
      syncthing.enable = true;
    };

    services.tailscale.enable = true;
    environment.systemPackages = with pkgs; [ bindfs ];
    systemd.services.oblivion-mount = {
      description = "Bindfs mount for ${stDataDir} -> ${obDataDir}";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.coreutils}/bin/mkdir -p ${obDataDir}"
          ''
            ${pkgs.bindfs}/bin/bindfs --force-user=aiden --force-group=users \
                        ${stDataDir} ${obDataDir}
          ''
        ];
        ExecStop = "${pkgs.util-linux}/bin/umount ${obDataDir}";
        RemainAfterExit = true;
      };
    };

  };
}
