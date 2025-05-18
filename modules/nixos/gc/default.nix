params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "gc" params {
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
