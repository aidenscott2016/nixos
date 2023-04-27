{ lib, pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ scala sbt metals ];
}
