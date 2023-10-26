{ lib, ... }:
with lib.aiden;
with lib; {
  enabled = { enabled = true; };
  enableableModule = name:
    params@{ config, ... }:
    configToEnable:
    let cfg = config.aiden.modules.${name};
    in {
      options.aiden.modules.${name}.enabled = mkOption {
        type = types.bool;
        default = false;
      };

      config = mkIf cfg.enabled configToEnable;
    };

}
