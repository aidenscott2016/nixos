{ ... }:
{
  flake.modules.nixos.oblivion-sync =
    { lib, pkgs, config, ... }:
    with lib;
    let
      cfg = config.aiden.modules.oblivionSync;
      obDataDir = cfg.obDataDir;
      stDataDir = cfg.stDataDir;
    in
    {
      options.aiden.modules.oblivionSync = {
        enable = mkEnableOption "oblivion sync";
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
      };

      config = mkIf cfg.enable {
        services.tailscale.enable = true;
        environment.systemPackages = with pkgs; [ bindfs ];

        # Create the directory on first boot if it doesn't exist; no-op if it does.
        # Syncthing is configured entirely via the UI — nothing here touches its state.
        systemd.tmpfiles.rules = [
          "d ${stDataDir} 0700 syncthing syncthing -"
        ];

        systemd.paths.oblivion-mount = {
          description = "Watch for Oblivion syncthing directory";
          wantedBy = [ "multi-user.target" ];
          pathConfig.PathExists = stDataDir;
        };

        systemd.services.oblivion-mount = {
          description = "Bindfs mount for ${stDataDir} -> ${obDataDir}";
          after = [ "syncthing.service" ];
          unitConfig.ConditionPathIsMountPoint = "!${obDataDir}";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              "${pkgs.coreutils}/bin/mkdir -p ${obDataDir}"
              "${pkgs.bindfs}/bin/bindfs --force-user=aiden --force-group=users ${stDataDir} ${obDataDir}"
            ];
            ExecStop = "${pkgs.util-linux}/bin/umount ${obDataDir}";
            RemainAfterExit = true;
          };
        };
      };
    };
}
