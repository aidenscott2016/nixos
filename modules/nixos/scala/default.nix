params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "scala" params {
  environment.systemPackages = with pkgs; [ scala sbt metals ];
}
