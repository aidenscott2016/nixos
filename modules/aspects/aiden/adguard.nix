{
  aiden.adguard.nixos =
    { config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.adguard or { };
      commonCfg = config.aiden.aspects.common or { };
      domainName = commonCfg.domainName or "sw1a1aa.uk";
      fqdn = "adguard.${domainName}";
    in
    {
      options.aiden.aspects.adguard = {
        httpAddress = mkOption {
          type = types.str;
          default = "10.0.1.1:8081";
          description = "HTTP address for AdGuard Home";
        };
        dnsBindHosts = mkOption {
          type = types.listOf types.str;
          default = [ "127.0.0.2" ];
          description = "DNS bind hosts";
        };
        dnsPort = mkOption {
          type = types.int;
          default = 5354;
          description = "DNS port (mdns uses 5353)";
        };
      };

      config = {
        services.adguardhome = {
          enable = true;
          settings = {
            http.address = cfg.httpAddress or "10.0.1.1:8081";
            dns.bind_hosts = cfg.dnsBindHosts or [ "127.0.0.2" ];
            dns.port = cfg.dnsPort or 5354;
            users = [
              {
                name = "admin";
                password = "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
              }
            ];
          };
        };

        networking.hosts."10.0.1.1" = [ fqdn ];
      };
    };
}
