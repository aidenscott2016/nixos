{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.aiden.architecture;
in
{
  options.aiden.architecture = {
    cpu = mkOption {
      type = types.enum [
        "amd"
        "intel"
      ];
      description = "CPU architecture";
    };
    gpu = mkOption {
      type = types.enum [
        "amd"
        "intel"
        "nvidia"
      ];
      description = "GPU architecture";
    };
  };
}
