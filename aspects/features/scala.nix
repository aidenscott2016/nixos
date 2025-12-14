{ lib, ... }:
{
  flake.modules.nixos.scala = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.scala;
    in {
      options.aiden.modules.scala.enable = mkEnableOption "scala";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          scala
          sbt
          metals
        ];
      };
    };
}
