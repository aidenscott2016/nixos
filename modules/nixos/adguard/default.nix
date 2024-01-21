params@{ pkgs, lib, config, ... }:
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
      dns.bind_hosts = [ "10.0.0.1" ];
      dns.port = 5354; #avahi uses 5353
      users = [{
        name = "admin";
        password =
          "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
      }];
    };
  };

  networking.hosts."10.0.1.1" = [ fqdn ];



  services.traefik = {
    dynamicConfigOptions = {
      http.routers.adguard.service = "adguard";
      http.routers.adguard.entrypoints = "websecure";
      http.routers.adguard.rule = "Host(`adguard.sw1a1aa.uk`)";
      http.routers.adguard.tls = "true";
      http.services.adguard.loadbalancer.servers = [{ url = "http://10.0.1.1:8081"; }];
    };
  };


  # Servicesv.nginx = {
  #   enable = true;
  #   virtualHosts."adguard.i.narrowdivergent.co.uk" = {
  #     locations."/" = {
  #       proxyPass = "http://10.0.1.1:${toString http_port}/";
  #       proxyWebsockets = true;
  #       extraConfig = ''
  #         proxy_redirect ~^/(.*) $scheme://$http_host/$1;
  #       '';
  #     };
  #   };
  # };
}
  
