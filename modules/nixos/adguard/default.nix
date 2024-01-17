params@{ pkgs, lib, config, ... }:
with lib.aiden;
let
  http_port = 8080;
in
enableableModule "adguard" params {
  services.adguardhome = {
    enable = true;
    mutableSettings = false; # TODO: import the defaults
    settings = {
      http.address = "10.0.1.1:8080";

      dns.bootstrap_dns = [ "1.1.1.1" ]; # idk
      dns.bind_hosts = [ "10.0.0.1" ];
      dns.port = 5354; #avahi uses 5353
      users = [{
        name = "admin";
        password =
          "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
      }];
    };
  };

  networking.hosts."10.0.1.1" = [ "adguard.i.narrowdivergent.co.uk" ];
  services.nginx = {
    enable = true;
    virtualHosts."adguard.i.narrowdivergent.co.uk" = {
      locations."/" = {
        proxyPass = "http://10.0.1.1:${toString http_port}/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_redirect ~^/(.*) $scheme://$http_host/$1;
        '';
      };
    };
  };
}
  
