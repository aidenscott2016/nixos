{ lib, ... }:
{
  flake.nixosModules.router = { config, lib, ... }:
    with lib;
    with config.aiden.modules.router; {
      options.aiden.modules.router = {
        enable = mkEnableOption "router functionality";
        internalInterface = mkOption {
          type = types.str;
          description = "Internal network interface";
        };
        externalInterface = mkOption {
          type = types.str;
          description = "External network interface";
        };
        dns.enable = mkEnableOption "unbound dns";
        dnsmasq.enable = mkEnableOption "dnsmasq dhcp server";
      };
    };
}
