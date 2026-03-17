{ ... }:
{
  flake.modules.nixos.reverse-proxy =
    { pkgs, lib, config, ... }:
    with lib;
    let
      inherit (config.aiden.modules.common) domainName email;
      cfg = config.aiden.modules.reverseProxy;

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
              auth = mkOption {
                type = bool;
                default = true;
              };
            };
          });
        default = [ ];
      };

      toLocalReverseProxy = foldl' (
        acc:
        { name, port, proto, auth, ... }:
        recursiveUpdate acc {
          routers."${name}" = {
            service = name;
            rule = "Host(`${name}.sw1a1aa.uk`)";
            tls = true;
          } // (optionalAttrs auth {
            middlewares = [ "authelia" ];
          });
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
            http = recursiveUpdate (toLocalReverseProxy cfg.apps) {
              middlewares.authelia.forwardAuth = {
                address = "http://127.0.0.1:9092/api/authz/forward-auth";
                trustForwardHeader = true;
                authResponseHeaders = [
                  "Remote-User"
                  "Remote-Groups"
                  "Remote-Email"
                  "Remote-Name"
                ];
              };
            };
          };
        };
      };
    };
}
