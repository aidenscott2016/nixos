params@{ pkgs, lib, config, ... }:
with lib.aiden;
let
  inherit (config.aiden.modules.common) domainName email;
in
enableableModule "traefik" params {

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
    certs = {
      "${domainName}" = {
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.cloudflareToken.path;
        extraDomainNames = [ "*.${domainName}" ];
        dnsResolver = "1.1.1.1:53";
      };
    };
  };


  users.users.traefik.extraGroups = [ "acme" ]; # to read acme folder
  services.traefik = {
    enable = true;
    group = "podman";
    staticConfigOptions = {
      accessLog = { fields = { defaultMode = "keep"; headers.defaultMode = "keep"; }; };
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
            entrypoints = "websecure";
            rule = "HostRegexp(`{name:(.*)\.sw1a1aa\.uk}`)";
            tls = true;
          };
        };
        services = {
          bes = {
            loadbalancer = {
              serversTransport = "bes";
              passHostHeader = true;
              servers = [{ url = "https://bes.sw1a1aa.uk"; }];
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
}
