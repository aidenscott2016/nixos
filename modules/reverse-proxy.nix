{ ... }:
{
  flake.modules.nixos.reverse-proxy =
    { pkgs, lib, config, ... }:
    with lib;
    let
      inherit (config.aiden.modules.common) email;
      cfg = config.aiden.modules.reverseProxy;

      # The service subdomain zone is always sw1a1aa.uk regardless of the host's
      # own domainName (which might be e.g. "bes.sw1a1aa.uk").
      zone = "sw1a1aa.uk";

      mkReverseProxyAppsOption = mkOption {
        type =
          with types;
          listOf (submodule {
            options = {
              name = mkOption {
                type = str;
              };
              port = mkOption {
                type = int;
              };
              proto = mkOption {
                type = str;
                default = "http";
              };
            };
          });
        default = [ ];
      };

      toLocalReverseProxy = foldl' (
        acc:
        { name, port, proto, ... }:
        recursiveUpdate acc {
          routers."${name}" = {
            service = name;
            rule = "Host(`${name}.${zone}`)";
            tls = true;
          };
          services."${name}" = {
            loadbalancer = {
              servers = [ { url = "${proto}://127.0.0.1:${toString port}"; } ];
            };
          };
        }
      ) { };
    in
    {
      options.aiden.modules.reverseProxy = {
        apps = mkReverseProxyAppsOption;
      };

      config = {
        # Provision a wildcard cert for *.sw1a1aa.uk via Cloudflare DNS-01.
        # The host must declare age.secrets.cloudflareToken.
        security.acme = {
          acceptTerms = true;
          defaults.email = email;
          certs."${zone}" = {
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.cloudflareToken.path;
            extraDomainNames = [ "*.${zone}" ];
            dnsResolver = "1.1.1.1:53";
          };
        };

        users.users.traefik.extraGroups = [ "acme" ];
        services.traefik = {
          enable = true;
          staticConfigOptions = {
            accessLog = {
              format = "json";
              fields = {
                defaultMode = "keep";
                headers.defaultMode = "keep";
              };
            };
            global = {
              checkNewVersion = false;
              sendAnonymousUsage = false;
            };
            entrypoints = {
              websecure = {
                forwardedHeaders.trustedIPs = [ "10.0.1.1" ];
                address = ":443";
              };
            };
          };
          dynamicConfigOptions = {
            http = toLocalReverseProxy cfg.apps;
            tls.stores.default = {
              defaultCertificate = {
                certFile = "/var/lib/acme/${zone}/fullchain.pem";
                keyFile  = "/var/lib/acme/${zone}/key.pem";
              };
            };
          };
        };
      };
    };
}
