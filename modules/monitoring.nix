{ inputs, ... }:
{
  flake.modules.nixos.monitoring =
    { config, pkgs, ... }:
    {
      age.secrets.grafana-admin-password = {
        file = "${inputs.self.outPath}/secrets/grafana-admin-password.age";
        owner = "grafana";
        mode = "0400";
      };

      # ── Exporters (localhost-only) ─────────────────────────────────────────

      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9100;
        # systemd and processes are not enabled by default; the rest are.
        enabledCollectors = [ "systemd" "processes" ];
      };

      services.prometheus.exporters.smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9633;
      };

      # ── Prometheus ─────────────────────────────────────────────────────────

      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9090;
        retentionTime = "30d";
        globalConfig.scrape_interval = "30s";
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
          }
          {
            job_name = "smartctl";
            static_configs = [ { targets = [ "127.0.0.1:9633" ]; } ];
          }
          {
            job_name = "traefik";
            static_configs = [ { targets = [ "127.0.0.1:8082" ]; } ];
          }
        ];
      };

      # ── Traefik metrics endpoint ───────────────────────────────────────────
      # Merges with the existing reverse-proxy.nix Traefik config. The
      # "metrics" entrypoint is bound to loopback so it is never reachable
      # from the network.

      services.traefik.staticConfigOptions = {
        entrypoints.metrics.address = "127.0.0.1:8082";
        metrics.prometheus = {
          entryPoint = "metrics";
          addEntryPointsLabels = true;
          addRoutersLabels = true;
          addServicesLabels = true;
        };
      };

      # ── Loki ───────────────────────────────────────────────────────────────

      services.loki = {
        enable = true;
        configuration = {
          auth_enabled = false;

          server = {
            http_listen_address = "127.0.0.1";
            http_listen_port = 3100;
            grpc_listen_port = 0;
          };

          common = {
            path_prefix = "/var/lib/loki";
            replication_factor = 1;
            ring.kvstore.store = "inmemory";
            storage.filesystem = {
              chunks_directory = "/var/lib/loki/chunks";
              rules_directory = "/var/lib/loki/rules";
            };
          };

          schema_config.configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];

          limits_config = {
            retention_period = "336h";
          };

          compactor = {
            working_directory = "/var/lib/loki/compactor";
            retention_enabled = true;
            delete_request_store = "filesystem";
          };
        };
      };

      # ── Promtail ───────────────────────────────────────────────────────────
      # The NixOS module automatically adds promtail to the systemd-journal
      # group when a journal scrape_config is detected.

      services.promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = 9080;
            grpc_listen_port = 0;
          };

          clients = [ { url = "http://127.0.0.1:3100/loki/api/v1/push"; } ];

          scrape_configs = [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = "bes";
                };
              };
              relabel_configs = [
                {
                  source_labels = [ "__journal__systemd_unit" ];
                  target_label = "unit";
                }
                {
                  source_labels = [ "__journal_priority_keyword" ];
                  target_label = "priority";
                }
              ];
            }
          ];
        };
      };

      # Ensure Promtail waits for Loki to be ready before pushing.
      systemd.services.promtail.after = [ "loki.service" ];
      systemd.services.promtail.wants = [ "loki.service" ];

      # ── Grafana ─────────────────────────────────────────────────────────────

      services.grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            domain = "grafana.sw1a1aa.uk";
            root_url = "https://grafana.sw1a1aa.uk";
          };

          security = {
            # $__file{} reads the password from the agenix-decrypted secret
            # at runtime; it is never embedded in the Nix store.
            admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
            disable_initial_admin_creation = false;
          };

          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
            check_for_plugin_updates = false;
          };
        };

        provision.datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:9090";
              isDefault = true;
              editable = false;
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://127.0.0.1:3100";
              editable = false;
            }
          ];
        };
      };

      # Grafana must start after the agenix secret is decrypted.
      systemd.services.grafana.after = [ "agenix.service" ];
      systemd.services.grafana.wants = [ "agenix.service" ];

      # ── Reverse proxy ──────────────────────────────────────────────────────

      aiden.modules.reverseProxy.apps = [
        { name = "grafana"; port = 3000; }
      ];
    };
}
