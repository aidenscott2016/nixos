params@{ pkgs, lib, config, ... }:
with lib.aiden;
{
  options.aiden.modules.avahi = with lib; {
    enabled = mkEnableOption "";
  };
  config = {
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      openFirewall = true;
    };
  };
}
