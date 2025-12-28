{ nd, ... }: {
  nd.router = {
    nixos =
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./_dhcp
    ./_dns
    ./_firewall
    ./_interfaces
    ./_zeroconf
  ];

  options.narrowdivergent.aspects.router = {
    internalInterface = mkOption { type = types.str; };
    externalInterface = mkOption { type = types.str; };
    dns.enable = mkEnableOption "unbound dns";
    dnsmasq.enable = mkEnableOption "dnsmasq";
  };
}
;
  };
}
