{ ... }:
{
  flake.modules.nixos.hardware-acceleration =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.modules.hardware-acceleration;
      inherit (config.aiden) architecture;
    in
    {
      options.aiden.modules.hardware-acceleration = {
        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Additional packages to install for hardware acceleration";
        };
      };

      config = {
        hardware = {
          enableAllFirmware = true;
          enableRedistributableFirmware = true;
          intel-gpu-tools.enable = true;
          amdgpu = mkIf (architecture.gpu == "amd") {
            amdvlk = {
              enable = true;
              support32Bit.enable = true;
            };

            initrd.enable = true;
          };

          graphics = {
            enable = true;
            extraPackages =
              with pkgs;
              [
                libva
                mesa
              ]
              #++ optionals (architecture.gpu == "amd") [ amdvlk ]
              ++ optionals (architecture.cpu == "intel") [
                intel-media-driver-stable
                libva-vdpau-driver
                intel-compute-runtime-legacy1
                vpl-gpu-rt
                intel-ocl
              ]
              ++ cfg.extraPackages;
          };
        };

        services.xserver = mkIf config.services.xserver.enable {
          videoDrivers = singleton (
            if architecture.gpu == "amd" then
              "amdgpu"
            else if architecture.gpu == "intel" then
              "intel"
            else
              "nvidia"
          );
        };

        environment.systemPackages = with pkgs; [ nvtopPackages.full ];
      };
    };
}
