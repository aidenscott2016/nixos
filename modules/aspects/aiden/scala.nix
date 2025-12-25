{
  aiden.scala.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.scala or { };
    in
    {
      options.aiden.aspects.scala = {
        enable = mkEnableOption "Scala development tools";
      };

      config = mkIf (cfg.enable or false) {
        environment.systemPackages = with pkgs; [
          scala
          sbt
          metals
        ];
      };
    };
}
