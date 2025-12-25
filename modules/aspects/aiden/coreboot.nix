{
  aiden.coreboot.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.coreboot or { };
    in
    {
      options.aiden.aspects.coreboot = {
        enable = mkEnableOption "Coreboot utilities";
      };

      config = mkIf (cfg.enable or false) {
        environment.systemPackages = with pkgs; [
          coreboot-utils
          flashrom
          bintools-unwrapped
        ];
      };
    };
}
