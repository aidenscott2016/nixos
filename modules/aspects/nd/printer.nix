{ nd, ... }: {
  nd.printer = {
    nixos =
{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    services = {
      avahi.enable = true;
      avahi.nssmdns4 = true;
      printing = {
        enable = true;
        drivers = [ pkgs.hplip ];
      };
    };
  };
}
;
  };
}
