{ lib, ... }:
{
  flake.nixosModules.adguard = { config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.modules.adguard;
      http_port = 8081;
      inherit (config.aiden.modules.common) domainName;
      fqdn = "adguard.${domainName}";
    in {
      options.aiden.modules.adguard.enable = mkEnableOption "adguard DNS blocker";

      config = mkIf cfg.enable {
        services.adguardhome = {
          enable = true;
          settings = {
            http.address = "10.0.1.1:8081";
            dns.bind_hosts = [ "127.0.0.2" ];
            dns.port = 5354; # mdns uses 5353
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
    };
}
