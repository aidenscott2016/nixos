params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.narrowdivergent;
enableableModule "scala" params {
  environment.systemPackages = with pkgs; [
    scala
    sbt
    metals
  ];
}
