{ ... }:
{
  flake.modules.nixos.scala =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        environment.systemPackages =  [
          scala
          sbt
          metals
        ];
    };
}
