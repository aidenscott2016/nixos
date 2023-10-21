{ config, pkgs, lib, myModulesPath, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    "${myModulesPath}/ios.nix"
    "${myModulesPath}/redshift.nix"
    "${myModulesPath}/printer.nix"
    "${myModulesPath}/ssh.nix"
    "${myModulesPath}/gc.nix"
    "${myModulesPath}/barrier.nix"
    # "${myModulesPath}/transmission.nix"
    "${myModulesPath}/jellyfin.nix"
    "${myModulesPath}/cli-base.nix"
    "${myModulesPath}/desktop.nix"
    "${myModulesPath}/nixos.nix"
    "${myModulesPath}/multimedia.nix"
    "${myModulesPath}/emacs.nix"
    #"${myModulesPath}/steam.nix"
    #"${myModulesPath}/virtualbox.nix"
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

  networking.hostName = "locutus";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  services = {
    fstrim.enable = true;
    upower.enable = true;
    auto-cpufreq.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    xserver.enable = true;
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 1;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 85;
        START_CHARGE_THRESH_BAT1 = 50;
        STOP_CHARGE_THRESH_BAT1 = 85;
      };

    };
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;

  services.gvfs.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/London";
      image =
        "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [ "--network=host" ];
    };
  };

  specialisation = {
    rpi-dev.configuration = {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
  };

  #avahi
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.domain = true;
  };

  system.stateVersion = "22.05";

  services = { tailscale.enable = true; };

}
