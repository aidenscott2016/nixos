{
  aiden.reverse-proxy.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.reverse-proxy or { };
      commonCfg = config.aiden.aspects.common or { };
      domainName = commonCfg.domainName or "sw1a1aa.uk";

      # Convert apps list to Traefik dynamic config
      toLocalReverseProxy = apps:
        let
          makeRouter = app: {
            name = app.name;
            value = {
              service = app.name;
              entrypoints = "websecure";
              rule = "Host(`${app.name}.${domainName}`)";
              tls = true;
            };
          };
          makeService = app: {
            name = app.name;
            value = {
              loadbalancer = {
                servers = [{ url = "http://127.0.0.1:${toString app.port}"; }];
              };
            };
          };
        in
        {
          routers = builtins.listToAttrs (map makeRouter apps);
          services = builtins.listToAttrs (map makeService apps);
        };
    in
    {
      options.aiden.aspects.reverse-proxy = {
        enable = mkEnableOption "Traefik reverse proxy for local services";
        apps = mkOption {
          type = types.listOf (types.submodule {
            options = {
              name = mkOption {
                type = types.str;
                description = "Name of the application (used for subdomain)";
              };
              port = mkOption {
                type = types.port;
                description = "Local port the application listens on";
              };
            };
          });
          default = [ ];
          description = "List of applications to reverse proxy";
        };
      };

      config = mkIf (cfg.enable or false) {
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
            http = toLocalReverseProxy cfg.apps;
          };
        };
      };
    };
}
