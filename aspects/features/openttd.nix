{ lib, ... }:
{
  flake.modules.nixos.openttd = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.programs.openttd;
    in {
      options.aiden.programs.openttd.enable = mkEnableOption "install openttd game";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ openttd ];
      };
    };
}
