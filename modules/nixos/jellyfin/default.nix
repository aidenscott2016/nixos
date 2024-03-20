params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "jellyfin" params {

  environment.systemPackages = [ pkgs.rename ];
  users.users.aiden.extraGroups = ["render"];
  services = {
    jellyfin = {
      user = "aiden";
      enable = true;
      openFirewall = true;
    };
  };
}
