{ nd, ... }: {
  nd.reverse-proxy = {
    nixos =
{ pkgs, lib, config, ... }:
with lib.narrowdivergent;
with lib;
let
  inherit (config.narrowdivergent.aspects.common) domainName email;
  cfg = config.narrowdivergent.aspects.reverseProxy;
in
{
  options.narrowdivergent.aspects.reverseProxy = {
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
;
  };
}
