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
      accessLog = { };
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
      providers.docker = {
        exposedByDefault = false;
        endpoint = "unix:///var/run/podman/podman.sock";
      };
      api.dashboard = true;
      api.insecure = true;
      entrypoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure.address = ":443";
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          jellyfin = {
            service = "jellyfin";
            entrypoints = "websecure";
            rule = "Host(`jellyfin.sw1a1aa.uk`)";
            tls = true;
          };
        };
        services = {
          jellyfin = {
            loadbalancer = {
              servers = [{ url = "http://bes.sw1a1aa.uk:8096"; }];
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
