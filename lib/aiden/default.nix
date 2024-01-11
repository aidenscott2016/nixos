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
        description = "Enable the ${name} module";
      };

      config = mkIf cfg.enabled configToEnable;
    };
}
