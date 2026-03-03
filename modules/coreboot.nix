{ ... }:
{
  flake.modules.nixos.coreboot =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        environment.systemPackages =  [
          coreboot-utils
          flashrom
          bintools-unwrapped
        ];
    };
}
