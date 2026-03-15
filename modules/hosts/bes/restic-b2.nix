{ inputs, ... }:
{
  flake.modules.nixos.restic-b2 =
    { config, pkgs, ... }:
    {
      age.secrets.restic-b2-env = {
        file = "${inputs.self.outPath}/secrets/restic-b2-env.age";
        owner = "restic";
      };
      age.secrets.restic-b2-password = {
        file = "${inputs.self.outPath}/secrets/restic-b2-password.age";
        owner = "restic";
      };

      users.users.restic = {
        isSystemUser = true;
        uid = 901;
        group = "restic";
        # immich group: read access to /media/t7/photos
        # media group: read access to /srv/media/Music
        extraGroups = [ "immich" "media" ];
      };
      users.groups.restic = { gid = 901; };

      services.restic.backups.b2 = {
        user = "restic";
        paths = [
          "/media/t7/photos"
          "/srv/media/Music/library/Cocteau Twins/1993 - Four-Calendar Café"
        ];
        repository = "s3:s3.eu-central-003.backblazeb2.com/backup-uwdcrk";
        environmentFile = config.age.secrets.restic-b2-env.path;
        passwordFile = config.age.secrets.restic-b2-password.path;
        initialize = true;
        createWrapper = true;
        timerConfig = {
          OnCalendar = "daily";
          Persistent = "true";
        };
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
          "--keep-yearly 2"
        ];
      };

      # UID-based bandwidth shaping via tc HTB + nftables fwmark.
      # Daytime (0700-2200): 5 Mbit/s upload cap. Nighttime: effectively unlimited.
      # Uses tc class change to adjust the rate in-place without interrupting uploads.
      networking.nftables.enable = true;
      networking.nftables.tables.restic-mark = {
        family = "inet";
        content = ''
          define RESTIC_UID = 901

          chain output-mark {
            type filter hook output priority mangle; policy accept;
            meta skuid $RESTIC_UID meta mark set 0x00000001
          }
        '';
      };

      systemd.services.restic-tc-setup = {
        description = "tc bandwidth shaping for restic (UID-based)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.iproute2 ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "restic-tc-setup" ''
            IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
            tc qdisc del dev "$IFACE" root 2>/dev/null || true
            tc qdisc add dev "$IFACE" root handle 1: htb default 10
            tc class add dev "$IFACE" parent 1:  classid 1:1  htb rate 1gbit ceil 1gbit
            tc class add dev "$IFACE" parent 1:1 classid 1:10 htb rate 1gbit ceil 1gbit
            tc class add dev "$IFACE" parent 1:1 classid 1:20 htb rate 1gbit ceil 1gbit
            tc filter add dev "$IFACE" parent 1: protocol ip handle 1 fw classid 1:20
          '';
          ExecStop = pkgs.writeShellScript "restic-tc-teardown" ''
            IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
            tc qdisc del dev "$IFACE" root || true
          '';
        };
      };

      systemd.services.restic-tc-day = {
        description = "Throttle restic to 5 Mbit (daytime 0700-2200)";
        after = [ "restic-tc-setup.service" ];
        requires = [ "restic-tc-setup.service" ];
        path = [ pkgs.iproute2 ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "restic-tc-day" ''
            IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
            tc class change dev "$IFACE" parent 1:1 classid 1:20 htb rate 5mbit ceil 5mbit
          '';
        };
      };

      systemd.timers.restic-tc-day = {
        description = "Throttle restic at 07:00";
        wantedBy = [ "timers.target" ];
        timerConfig = { OnCalendar = "*-*-* 07:00:00"; Persistent = true; };
      };

      systemd.services.restic-tc-night = {
        description = "Unthrottle restic (nighttime 2200-0700)";
        after = [ "restic-tc-setup.service" ];
        requires = [ "restic-tc-setup.service" ];
        path = [ pkgs.iproute2 ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "restic-tc-night" ''
            IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
            tc class change dev "$IFACE" parent 1:1 classid 1:20 htb rate 1gbit ceil 1gbit
          '';
        };
      };

      systemd.timers.restic-tc-night = {
        description = "Unthrottle restic at 22:00";
        wantedBy = [ "timers.target" ];
        timerConfig = { OnCalendar = "*-*-* 22:00:00"; Persistent = true; };
      };
    };
}
