{ nd, ... }: {
  nd.syncthing = {
    nixos =
{ lib, pkgs, config, ... }:
{
  config = {
    users.users.syncthing.extraGroups = [ "video" ];
    users.users.aiden.extraGroups = [ "syncthing" ];
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };
}
;
  };
}
