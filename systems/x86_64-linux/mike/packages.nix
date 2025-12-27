{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    naps2
    antigravity-fhs
  ];
}
