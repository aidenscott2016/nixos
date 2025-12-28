{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Packages have been moved to the desktop composition module
  # (modules/nixos/desktop/default.nix)
  environment.systemPackages = with pkgs; [ ];
}
