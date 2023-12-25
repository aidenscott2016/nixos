params@{ pkgs, lib, config, ... }:
with lib.aiden;
let
  http_port = 8080;
  host = "10.0.0.2";
in
enableableModule "adguard" params {
  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        bind_host = host;
        bind_port = http_port;
      };
      dns.bind_hosts = [host];
      users = [{
        name = "admin";
        password =
          "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
      }];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."gila.local" = {
      locations."/adguard" = {
        proxyPass = "http://127.0.0.1:${toString http_port}";
        proxyWebsockets = true;
      };
    };
  };
}
