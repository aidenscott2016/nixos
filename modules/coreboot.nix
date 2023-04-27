{ lib, pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [
    coreboot-utils
    flashrom
    bintools-unwrapped
  ];
}
