params@{ pkgs, lib, config, ... }:
with lib.aiden;
with lib;
let
  inherit (config.aiden.modules.common) domainName email;
  cfg = config.aiden.modules.reverseProxy;
in
{
  options.aiden.modules.reverseProxy = {
    enabled = mkEnableOption "";
    apps = lib.aiden.types.mkReverseProxyAppsOption;
  };

  config = mkIf cfg.enabled {
    users.users.traefik.extraGroups = [ "acme" "podman" ]; # to read acme folder
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        log.level = "DEBUG";
        accessLog = { fields = {defaultMode = "keep"; headers.defaultMode = "keep";};};
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
        };
        entrypoints = {
          web = {
            address = ":80";
            # http.redirections.entrypoint = {
            #   to = "websecure";
            #   scheme = "https";
            # };
          };
          websecure = {address = ":443";};
        };
      };
      dynamicConfigOptions = {
        http = toLocalReverseProxy cfg.apps;

        # tls = {
        #   stores.default = {
        #     defaultCertificate = {
        #       certFile = "/var/lib/acme/${domainName}/fullchain.pem";
        #       keyFile = "/var/lib/acme/${domainName}/key.pem";
        #     };
        #   };
        # };
      };
    };
  };
}
