{ ... }:
{
  flake.modules.nixos.adguard =
    { pkgs, lib, config, ... }:
    let
      inherit (config.aiden.modules.common) domainName email;
      fqdn = "adguard.${domainName}";
    in
    {
        services.adguardhome = {
          enable = true;
          host = "10.0.1.1";
          port = 8081;
          settings = {
            # AdGuard is the first-hop DNS for all VLANs so it can see client IPs.
            # It forwards sw1a1aa.uk queries to BIND on 127.0.0.1:5353, and
            # everything else to upstream resolvers.
            dns = {
              bind_hosts = [
                "127.0.0.2"
                "10.0.0.1"
                "10.0.1.1"
                "10.0.2.1"
                "10.0.3.1"
              ];
              port = 53;
              upstream_dns = [
                "[/sw1a1aa.uk/]127.0.0.1:5353"
                "https://dns.cloudflare.com/dns-query"
                "https://dns.google/dns-query"
              ];
              bootstrap_dns = [
                "1.1.1.1"
                "8.8.8.8"
              ];
            };
            users = [
              {
                name = "admin";
                password = "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
              }
            ];
          };
        };

        networking.hosts."10.0.1.1" = [ fqdn ];

        services.traefik = {
          dynamicConfigOptions = {
            http.routers.adguard.service = "adguard";
            http.routers.adguard.entrypoints = "websecure";
            http.routers.adguard.rule = "Host(`${fqdn}`)";
            http.routers.adguard.tls = "true";
            http.services.adguard.loadbalancer.servers = [ { url = "http://10.0.1.1:8081"; } ];
          };
        };
    };
}
