{
  aiden.oblivion-sync.nixos =
    { pkgs, config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.oblivion-sync or { };
      obDataDir = cfg.obDataDir or "/home/aiden/oblivion-sync";
      stDataDir = cfg.stDataDir or "${config.services.syncthing.dataDir}/Oblivion";
    in
    {
      options.aiden.aspects.oblivion-sync = {
        stDataDir = mkOption {
          description = "source directory for oblivion saves";
          type = types.path;
          default = "${config.services.syncthing.dataDir}/Oblivion";
        };
        obDataDir = mkOption {
          description = "mount point for oblivion saves";
          type = types.path;
          default = "/home/aiden/oblivion-sync";
        };
      };

      config = {
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
    };
}
