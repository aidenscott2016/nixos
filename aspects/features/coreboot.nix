{ lib, ... }:
{
  flake.modules.nixos.coreboot = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.coreboot;
    in {
      options.aiden.modules.coreboot.enable = mkEnableOption "coreboot";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          coreboot-utils
          flashrom
          bintools-unwrapped
        ];
      };
    };
}
