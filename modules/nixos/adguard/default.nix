params@{ pkgs, lib, config, ... }:
with lib.aiden;
let port = 8080; in
enableableModule "adguard" params {
  services.adguardhome = {
    enable = true;
    settings.bind_port = port;
    settings.users = [{
      name = "admin";
      password =
        "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
    }];
  };

  services.nginx = {
    enable = true;
    virtualHosts."gila.local" = {
      locations."/adguard" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
