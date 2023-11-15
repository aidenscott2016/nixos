# https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
{ config, lib, pkgs, ... }:
with lib;
with config.aiden.modules.router; {
  config = mkIf enabled {

    # grafana configuration
    services.grafana = {
      enable = true;
      settings.server = {
        domain = "gila.local";
        http_port = 2342;
        http_addr = "127.0.0.1";
      };
    };

    # nginx reverse proxy
    services.nginx.enable = true;
    services.nginx.virtualHosts."gila.local" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${
            toString config.services.grafana.settings.server.http_port
          }";
        proxyWebsockets = true;
      };
    };
  };
}
