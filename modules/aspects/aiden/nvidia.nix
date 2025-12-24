{
  aiden.nvidia.nixos =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.nvidia or { };
      prime = cfg.prime or { };
      package = cfg.package or config.boot.kernelPackages.nvidiaPackages.stable;
    in
    {
      options.aiden.aspects.nvidia = {
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
        boot.initrd.kernelModules = [ "nvidia" ];

        hardware.nvidia = {
          prime = {
            intelBusId = prime.intelBusId or "PCI:0:2:0";
            nvidiaBusId = prime.nvidiaBusId or "PCI:1:0:0";
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
          };
          package = package;
          modesetting.enable = true;
          open = false;
          nvidiaSettings = true;
          powerManagement.enable = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];
      };
    };
}
