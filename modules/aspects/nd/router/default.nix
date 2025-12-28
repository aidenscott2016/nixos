<<<<<<< HEAD
||||||| parent of 2f50a24 (fix: update namespace references and prevent import-tree auto-import)
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
    ./dhcp
    ./dns
    ./firewall
    ./interfaces
    ./zeroconf
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
=======
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
>>>>>>> 2f50a24 (fix: update namespace references and prevent import-tree auto-import)
