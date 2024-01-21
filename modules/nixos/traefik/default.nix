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
      };
    };
  };


  users.users.traefik.extraGroups = [ "acme" ]; # to read acme folder
  services.traefik = {
    enable = true;
    group = "podman";
    staticConfigOptions = {
      accessLog = { };
      log.level = "DEBUG";
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
