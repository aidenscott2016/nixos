{
  aiden.scanner.nixos =
    { pkgs, ... }:
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
