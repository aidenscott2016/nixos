{ config, inputs, lib, pkgs, systems, ... }:
with lib.aiden;
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
  ];

  config = {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    networking.networkmanager.enable = true;
    services.openssh.enable = true;
    services.openssh.openFirewall = true;
    security.sudo.wheelNeedsPassword = false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    system.stateVersion = "23.11";
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.aiden = {
    };
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };


    aiden.modules = {
      common = {
        domainName = "tv.sw1a1aa.uk";
        enabled = true;

      };

      avahi = enabled;
      redshift = enabled;
      ssh = enabled;
      gc = enabled;
      cli-base = enabled;
      steam.enabled = false;
      locale = enabled;
    };

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs;[
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        intel-compute-runtime

      ];
    driSupport = true;
    };

    boot.kernelParams = [
      "i915.enable_guc=2"
    ];
    environment.systemPackages = with pkgs; [ firefox lm_sensors htop ];

  };
}
