{ config, lib, pkgs, ... }:
with lib;
with config.aiden.modules.router; {
  options.aiden.modules.router = {
    enabled = mkEnableOption "router";
    internalInterface = mkOption { type = types.str; };
    externalInterface = mkOption { type = types.str; };
    dns.enabled = mkEnableOption "unbound dns";
    kea.enabled = mkEnableOption "kea";
    dnsmasq.enabled = mkEnableOption "dnsmasq";
  };
}
