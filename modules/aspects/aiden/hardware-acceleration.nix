{
  aiden.hardware-acceleration.nixos =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.hardware-acceleration or { };
      architecture = config.aiden.aspects.architecture or { };
      extraPackages = cfg.extraPackages or [ ];
    in
    {
      options.aiden.aspects.hardware-acceleration = {
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
          amdgpu = mkIf (architecture.gpu or "" == "amd") {
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
              ++ optionals (architecture.gpu or "" == "amd") [ amdvlk ]
              ++ optionals (architecture.cpu or "" == "intel") [
                intel-media-driver-stable
                libva-vdpau-driver
                intel-compute-runtime-legacy1
                vpl-gpu-rt
                intel-ocl
              ]
              ++ extraPackages;
          };
        };

        services.xserver = mkIf config.services.xserver.enable {
          videoDrivers = singleton (
            if architecture.gpu or "" == "amd" then
              "amdgpu"
            else if architecture.gpu or "" == "intel" then
              "intel"
            else
              "nvidia"
          );
        };

        boot.kernelParams = optionals (architecture.cpu or "" == "intel") [
          "i915.enable_guc=3"
        ];

        environment.systemPackages = with pkgs; [ nvtopPackages.full ];
      };
    };
}
