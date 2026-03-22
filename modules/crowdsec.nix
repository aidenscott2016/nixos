{ inputs, ... }:
{
  flake.modules.nixos.crowdsec =
    { config, pkgs, lib, ... }:
    let
      geoipDir = "/var/lib/geoip";

      geoipUpdateScript = pkgs.writeShellScript "geoip-update" ''
        set -euo pipefail

        YEAR=$(date +%Y)
        MONTH=$(date +%m)
        URL="https://download.db-ip.com/free/dbip-country-lite-''${YEAR}-''${MONTH}.csv.gz"

        mkdir -p ${geoipDir}

        echo "Downloading DB-IP country lite from $URL"
        ${pkgs.curl}/bin/curl -sSfL "$URL" | ${pkgs.gzip}/bin/gzip -d > ${geoipDir}/dbip-country.csv

        echo "Extracting GB and IM IPv4 ranges"
        ${pkgs.gawk}/bin/awk -F',' '
          {
            gsub(/"/, "", $1); gsub(/"/, "", $2); gsub(/"/, "", $3)
            if (($3 == "GB" || $3 == "IM") && index($1, ":") == 0)
              print $1 "-" $2
          }
        ' ${geoipDir}/dbip-country.csv > ${geoipDir}/gb-im-ranges.txt

        RANGE_COUNT=$(wc -l < ${geoipDir}/gb-im-ranges.txt)
        echo "Found $RANGE_COUNT IPv4 ranges for GB/IM"

        {
          printf "flush set ip myfilter geoip_allowed\n"
          printf "add element ip myfilter geoip_allowed {\n"
          ${pkgs.gawk}/bin/awk 'NR > 1 { printf ",\n" } { printf "  " $0 }' ${geoipDir}/gb-im-ranges.txt
          printf "\n}\n"
        } > ${geoipDir}/geoip-update.nft

        echo "Applying nftables GeoIP set update"
        ${pkgs.nftables}/bin/nft -f ${geoipDir}/geoip-update.nft
        echo "GeoIP set updated with $RANGE_COUNT ranges"
      '';
    in
    {
      age.secrets.crowdsec-enroll-key = {
        file = "${inputs.self.outPath}/secrets/crowdsec-enroll-key.age";
        owner = "crowdsec";
        mode = "0400";
      };

      services.crowdsec = {
        enable = true;

        settings.general.api.server.enable = true;
        settings.lapi.credentialsFile = "/var/lib/crowdsec/state/local_api_credentials.yaml";

        hub = {
          collections = [
            "crowdsecurity/traefik"
            "crowdsecurity/sshd"
            "crowdsecurity/linux"
            "LePresidente/authelia"
          ];
          parsers = [
            "crowdsecurity/geoip-enrich"
          ];
        };

        localConfig.acquisitions = [
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=traefik.service" ];
            labels.type = "traefik";
          }
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
            labels.type = "syslog";
          }
        ];

        settings.general = {
          prometheus = {
            enabled = true;
            level = "full";
            listen_addr = "10.0.1.1";
            listen_port = 6060;
          };
        };
      };

      services.crowdsec-firewall-bouncer = {
        enable = true;
        createRulesets = true;
        registerBouncer.enable = true;
        settings.mode = "nftables";
      };

      systemd.services.crowdsec-firewall-bouncer.after = [ "crowdsec-firewall-bouncer-register.service" ];

      systemd.services.geoip-update = {
        description = "Update GeoIP nftables allowlist with GB/IM ranges";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" "nftables.service" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = geoipUpdateScript;
          RemainAfterExit = true;
        };
      };

      systemd.timers.geoip-update = {
        description = "Daily GeoIP database refresh";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      systemd.services.crowdsec.after = lib.mkAfter [ "agenix.service" ];
    };
}
