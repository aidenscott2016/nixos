params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "jellyfin" params {

  environment.systemPackages = [ pkgs.rename ];
  services = {
    jellyfin = {
      user = "aiden";
      enable = true;
      openFirewall = true;
    };
  };
}
