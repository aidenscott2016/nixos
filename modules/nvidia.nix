{ ... }:
{
  flake.modules.nixos.nvidia =
    { config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.modules.nvidia;
    in
    {
      options.aiden.modules.nvidia = {
        prime = {
          intelBusId = mkOption {
            type = types.str;
            default = "PCI:0:2:0";
            description = "Bus ID for the Intel GPU";
          };
          nvidiaBusId = mkOption {
            type = types.str;
            default = "PCI:1:0:0";
            description = "Bus ID for the NVIDIA GPU";
          };
        };
        package = mkOption {
          type = types.package;
          default = config.boot.kernelPackages.nvidiaPackages.stable;
          description = "NVIDIA driver package to use";
        };
      };

      config = {
        nixpkgs.config.nvidia.acceptLicense = true;

        hardware = {
          nvidia = {
            prime = {
              intelBusId = cfg.prime.intelBusId;
              nvidiaBusId = cfg.prime.nvidiaBusId;
              offload = {
                enable = true;
                enableOffloadCmd = true;
              };
            };
            package = cfg.package;
            modesetting.enable = true;
            open = false;
            nvidiaSettings = true;
            powerManagement.enable = true;
            powerManagement.finegrained = true;
          };
        };
      };
    };
}
