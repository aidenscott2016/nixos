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
            };
          });
        default = [ ];
      };

      toLocalReverseProxy = foldl' (
        acc:
        { name, port, proto, ... }:
        recursiveUpdate acc {
          routers."${name}" = {
            service = name;
            rule = "Host(`${name}.sw1a1aa.uk`)";
            tls = true;
          };
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
        dns = {
          enable = mkEnableOption "authoritative dnsmasq for registered apps";
          zone = mkOption {
            type = types.str;
            default = "sw1a1aa.uk";
            description = "DNS zone this host is authoritative for.";
          };
          selfIP = mkOption {
            type = types.str;
            default = "";
            description = "This host's own LAN IP. Must be set when dns.enable = true.";
          };
          ingressIP = mkOption {
            type = types.str;
            default = "10.0.1.1";
            description = ''
              IP that service subdomains resolve to. Should be the upstream
              Traefik ingress (gila's LAN IP) that terminates TLS and proxies
              requests to this host.
            '';
          };
        };
      };

      config = mkMerge [
        {
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
        }

        (mkIf cfg.dns.enable {
          # Run dnsmasq as the authoritative DNS server for cfg.dns.zone.
          # Each app in reverseProxy.apps gets an explicit A record pointing to
          # the ingress IP (gila's traefik). The host's own FQDN resolves to
          # selfIP directly. A zone-wide wildcard catches anything else in the
          # zone (e.g. gila.sw1a1aa.uk) via the ingress.
          services.resolved.enable = false;
          networking.nameservers = [ "127.0.0.1" ];
          networking.firewall.allowedTCPPorts = [ 53 ];
          networking.firewall.allowedUDPPorts = [ 53 ];
          services.dnsmasq = {
            enable = true;
            settings = {
              # Forward non-zone queries to public resolvers
              server = [ "1.1.1.1" "9.9.9.9" ];
              bogus-priv = true;
              domain-needed = true;
              address =
                # This host's own FQDN resolves to its LAN IP directly,
                # not via the ingress, so gila can reach bes without a loop.
                [ "/${domainName}/${cfg.dns.selfIP}" ]
                # One explicit record per registered app (all via the ingress)
                ++ map ({ name, ... }: "/${name}.${cfg.dns.zone}/${cfg.dns.ingressIP}") cfg.apps
                # Wildcard catch-all so hosts like gila.sw1a1aa.uk still resolve
                ++ [ "/${cfg.dns.zone}/${cfg.dns.ingressIP}" ];
            };
          };
        })
      ];
    };
}
