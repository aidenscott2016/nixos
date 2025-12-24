{
  aiden.traefik.nixos =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.traefik or { };
      commonCfg = config.aiden.aspects.common or { };
      domainName = commonCfg.domainName or "sw1a1aa.uk";
      email = commonCfg.email or "aiden@oldstreetjournal.co.uk";
    in
    {
      options.aiden.aspects.traefik = {
        cloudflareCredentialsFile = mkOption {
          type = types.str;
          description = "Path to Cloudflare credentials file";
        };
      };

      config = {
        security.acme = {
          acceptTerms = true;
          defaults.email = email;
          certs = {
            "${domainName}" = {
              dnsProvider = "cloudflare";
              credentialsFile = cfg.cloudflareCredentialsFile;
              extraDomainNames = [ "*.${domainName}" ];
              dnsResolver = "1.1.1.1:53";
            };
          };
        };

        users.users.traefik.extraGroups = [ "acme" ];

        services.traefik = {
          enable = true;
          group = "podman";
          staticConfigOptions = {
            api = {
              dashboard = true;
              insecure = true;
            };
            accessLog = {
              fields = {
                defaultMode = "keep";
                headers.defaultMode = "keep";
              };
            };
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
              serversTransports.bes.insecureSkipVerify = true;
              routers = {
                bes = {
                  service = "bes";
                  priority = 1;
                  entrypoints = "websecure";
                  rule = "HostRegexp(`^.+\\.sw1a1aa\\.uk$`)";
                  tls = true;
                };
              };
              services = {
                bes = {
                  loadbalancer = {
                    serversTransport = "bes";
                    passHostHeader = true;
                    servers = [ { url = "https://bes.sw1a1aa.uk"; } ];
                  };
                };
              };
            };

            tls = {
              stores.default = {
                defaultCertificate = {
                  certFile = "/var/lib/acme/${domainName}/fullchain.pem";
                  keyFile = "/var/lib/acme/${domainName}/key.pem";
                };
              };
            };
          };
        };
      };
    };
}
