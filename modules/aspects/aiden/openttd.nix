{
  aiden.openttd.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.openttd or { };
    in
    {
      options.aiden.aspects.openttd = {
        enable = mkEnableOption "OpenTTD game";
      };

      config = mkIf (cfg.enable or false) {
        environment.systemPackages = with pkgs; [ openttd ];
      };
    };
}
