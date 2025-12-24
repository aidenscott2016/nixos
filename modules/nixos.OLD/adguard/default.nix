params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
let
  http_port = 8081;
  inherit (config.aiden.modules.common) domainName email;
  fqdn = "adguard.${domainName}";
in
enableableModule "adguard" params {
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
}
