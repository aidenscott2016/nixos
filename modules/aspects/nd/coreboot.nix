{ nd, ... }: {
  nd.coreboot = {
    nixos =
params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.narrowdivergent;
enableableModule "coreboot" params {
  environment.systemPackages = with pkgs; [
    coreboot-utils
    flashrom
    bintools-unwrapped
  ];
}
;
  };
}
