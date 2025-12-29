{ nd, ... }: {
  nd.barbie-hardware = {
    nixos = { config, lib, pkgs, ... }: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    boot.kernelParams = [
      "i915.enable_guc=2"
    ];

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    hardware.sensor.iio.enable = true;
    services.udev.extraHwdb = ''
      sensor:modalias:*
        ACCEL_MOUNT_MATRIX=-0, -1, 0; -1, 0, 0; 0, 0, 1
    '';

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        intel-compute-runtime
      ];
    };
    };
  };
}
