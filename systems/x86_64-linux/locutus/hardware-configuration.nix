{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "ehci_pci"
    "xhci_pci"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "amd-gpu"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/133d9b05-420b-4fcd-93b7-a1c718986049";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7b61d67c-fd18-4ab6-86ff-50510b7c727d";
    neededForBoot = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/31A5-7A7C";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/home/nix";
    neededForBoot = true;
    options = [
      "bind"
      "x-systemd.requires=/home"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/b2262156-a602-477d-a5e7-627588045a5f"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault false;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0f3u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;
  #
  #

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
