{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  ip = "10.0.0.1";
in
{
  networking.hosts."${ip}" = [ "grafana.sw1a1aa.uk" ];
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.sw1a1aa.uk";
        http_port = 2342;
        http_addr = ip;
      };
    };
  };
  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enableCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "locutus-node-exporter";
        metrics_path = "/metrics/node";
        scheme = "https";
        static_configs = [
          {
            targets = [ "locutus.sw1a1aa.uk" ];
          }
        ];
      }
      {
        job_name = "gila-node-exporter";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
    ];
  };
  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers = {
          grafana = {
            service = "grafana";
            entrypoints = "websecure";
            rule = "Host(`grafana.sw1a1aa.uk`)";
            tls = true;
          };
        };
        services = {
          grafana = {
            loadbalancer = {
              servers = [ { url = "http://${ip}:2342"; } ];
            };
          };
        };
      };
    };
  };
}
