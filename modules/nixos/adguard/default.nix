params@{ pkgs, lib, config, ... }:
with lib.aiden;
let
  http_port = 8080;
in
enableableModule "adguard" params {
  services.adguardhome = {
    enable = true;
    settings = {
      bind_host = "10.0.1.1";
      bind_port = http_port;
      dns.port = 5354; #avahi uses 5353
      users = [{
        name = "admin";
        password =
          "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
      }];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."gila.oldstreetjournal.co.uk" = {
      locations."/adguard/" = {
        proxyPass = "http://10.0.1.1:${toString http_port}/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_redirect ~^/(.*) $scheme://$http_host/adguard/$1;
        '';
      };
    };
  };
}
  
