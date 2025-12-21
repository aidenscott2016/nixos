params@{
  config,
  pkgs,
  inputs,
  channels,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    naps2
  ];
}
