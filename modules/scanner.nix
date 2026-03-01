{ ... }:
{
  flake.modules.nixos.scanner =
    { lib, pkgs, config, ... }:
    {
      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
        drivers.scanSnap.enable = true;
      };
      users.users.aiden.extraGroups = [
        "scanner"
        "lp"
      ];
    };
}
