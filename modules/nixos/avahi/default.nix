params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "avahi" params {
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
}
