{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with config.aiden.modules.router;
{
  options.aiden.modules.router = {
    enable = mkEnableOption "router";
    internalInterface = mkOption { type = types.str; };
    externalInterface = mkOption { type = types.str; };
    dns.enable = mkEnableOption "unbound dns";
    dnsmasq.enable = mkEnableOption "dnsmasq";
  };
}
