params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "traefik" params {
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
            certFile = "/var/lib/acme/sw1a1aa.uk/fullchain.pem";
            keyFile = "/var/lib/acme/sw1a1aa.uk/key.pem";
          };
        };
      };
    };
  };
}
