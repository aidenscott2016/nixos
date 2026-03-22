{ inputs, ... }:
{
  flake.modules.nixos.crowdsec =
    { config, pkgs, lib, ... }:
    {
      age.secrets.crowdsec-enroll-key = {
        file = "${inputs.secrets}/crowdsec-enroll-key.age";
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

      systemd.services.crowdsec.after = lib.mkAfter [ "agenix.service" ];
    };
}
