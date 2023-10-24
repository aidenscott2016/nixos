{ config, pkgs, lib, ... }:
{
  services = {
    avahi.enable = true;
    avahi.nssmdns = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
  };
}
