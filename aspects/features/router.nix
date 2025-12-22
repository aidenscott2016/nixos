{ lib, ... }:
{
  flake.modules.nixos.router = { config, lib, ... }:
    with lib;
    with config.aiden.modules.router; {
      options.aiden.modules.router = {
        enable = mkEnableOption "router functionality";
        internalInterface = mkOption {
          type = types.str;
          default = "eth1"; # Default to eth1
          description = "Internal network interface";
        };
        externalInterface = mkOption {
          type = types.str;
          default = "eth0"; # Default to eth0
          description = "External network interface";
        };
        dns.enable = mkEnableOption "unbound dns";
        dnsmasq.enable = mkEnableOption "dnsmasq dhcp server";
      };
    };
}
