params@{ pkgs, lib, config, inputs, ... }:
with lib;
with lib.types;
let
  cfg = config.aiden.modules.node-exporter;
  fqdn = locutus.sw1a1aa.uk
{
  options.aiden.moduels.node-exporter = {
    enable = mkEnableOption "";
    fqdn = mkOption {
      type = types.str;
      default = config.modules.common.domainName;
      
    };
  };
  config = mkIf cfg.enable {
    age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
    security.acme = {
      acceptTerms = true;
      defaults.email = "aiden@oldstreetjournal.co.uk";
      certs = {
        "" = {
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.cloudflareToken.path;
          dnsResolver = "1.1.1.1:53";
        };
      };
    };

    users.users.traefik.extraGroups = [ "acme" "podman" ]; # to read acme folder
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
        };
        providers.docker = {
          exposedByDefault = false;
          endpoint = "unix:///var/run/podman/podman.sock";
        };
        entrypoints = {
          websecure.address = ":443";
        };
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            metrics = {
              service = "nodeexporter";
              entrypoints = "websecure";
              rule = "Host(`locutus.sw1a1aa.uk`) && PathPrefix(`/metrics/node`)";
              tls = true;
              middlewares = "metricsRewrite";
            };
          };
          middlewares = {
            metricsRewrite = {
              replacepath.path = "/metrics";
            };
          };
          services = {
            nodeexporter = {
              loadbalancer = {
                servers = [{ url = "http://locutus.sw1a1aa.uk:${toString config.services.prometheus.exporters.node.port}"; }];
                #servers = [{ url = "http://locutus.sw1a1aa.uk:9999"; }];
              };
            };
          };
        };

        tls = {
          stores.default = {
            defaultCertificate = {
              certFile = "/var/lib/acme/locutus.sw1a1aa.uk/fullchain.pem";
              keyFile = "/var/lib/acme/locutus.sw1a1aa.uk/key.pem";
            };
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
