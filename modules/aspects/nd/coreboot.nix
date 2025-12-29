params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "coreboot" params {
  environment.systemPackages = with pkgs; [
    coreboot-utils
    flashrom
    bintools-unwrapped
  ];
}
