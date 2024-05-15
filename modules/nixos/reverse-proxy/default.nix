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
        accessLog = {
          format = "json";
          fields = { defaultMode = "keep"; headers.defaultMode = "keep"; };
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
