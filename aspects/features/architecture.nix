{ lib, ... }:
{
  flake.nixosModules.architecture = { lib, ... }:
    with lib; {
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
    };
}
