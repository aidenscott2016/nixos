{ ... }:
{
  flake.modules.nixos.syncthing =
    { lib, pkgs, config, ... }:
    {
      users.users.syncthing.extraGroups = [ "video" ];
      users.users.aiden.extraGroups = [ "syncthing" ];
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };
    };
}
