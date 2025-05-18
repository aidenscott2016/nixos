params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "printer" params {
  services = {
    avahi.enable = true;
    avahi.nssmdns4 = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
  };
}
