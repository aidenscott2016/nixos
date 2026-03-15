{ ... }:
{
  flake.modules.nixos.media-storage =
    { pkgs, ... }:
    {
      users.groups.media = { };

      users.users.aiden.extraGroups = [ "media" ];

      environment.systemPackages = [ pkgs.bindfs ];

      systemd.services.media-bindfs = {
        description = "Bindfs mount /media/t7 -> /srv/media";
        after = [ "media-t7.mount" ];
        requires = [ "media-t7.mount" ];
        wantedBy = [ "multi-user.target" ];
        unitConfig.ConditionPathIsMountPoint = "!/srv/media";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.coreutils}/bin/mkdir -p /srv/media"
            "${pkgs.bindfs}/bin/bindfs --force-user=aiden --force-group=media --create-for-user=aiden --create-for-group=media --perms=ug+rwX,o+rX --create-with-perms=ug+rw,o+r /media/t7 /srv/media"
          ];
          ExecStop = "${pkgs.util-linux}/bin/umount /srv/media";
          RemainAfterExit = true;
        };
      };
    };
}
