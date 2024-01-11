params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "adguard" params {
  services.adguardhome = {
    enable = true;
    settings.bind_port = 8080;
    settings.users = [{
      name = "admin";
      password =
        "$2a$12$IVkJmQHIbxzi1G/HbvGZCuj16cVJ.kT8RrUz8TIaqcs04DcbSnkOi ";
    }];
  };
}
