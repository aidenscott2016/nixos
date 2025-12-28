{ nd, ... }: {
  nd.scanner = {
    nixos =
{ lib, pkgs, config, ... }:
{
  config = {
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
;
  };
}
