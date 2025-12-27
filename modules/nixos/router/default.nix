{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./dhcp
    ./dns
    ./firewall
    ./interfaces
    ./zeroconf
  ];

  options.aiden.modules.router = {
    internalInterface = mkOption { type = types.str; };
    externalInterface = mkOption { type = types.str; };
    dns.enable = mkEnableOption "unbound dns";
    dnsmasq.enable = mkEnableOption "dnsmasq";
  };
}
