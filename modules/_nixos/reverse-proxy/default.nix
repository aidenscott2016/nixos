{ pkgs, lib, config, ... }:
with lib.narrowdivergent;
with lib;
let
  inherit (config.narrowdivergent.modules.common) domainName email;
  cfg = config.narrowdivergent.modules.reverseProxy;
in
{
  options.narrowdivergent.modules.reverseProxy = {
    apps = lib.narrowdivergent.types.mkReverseProxyAppsOption;
  };

  config = {
    users.users.traefik.extraGroups = [ "acme" ]; # to read acme folder
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
      };
    };
  };
}
