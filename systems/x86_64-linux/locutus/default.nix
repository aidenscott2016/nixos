{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  aiden = {
    architecture = {
      cpu = "amd";
      gpu = "amd";
    };
    modules = {
      desktop = enabled;
      gc = enabled;
      gaming = {
        steam.enabled = true;
        moonlight.client.enabled = true;
      };
      virtualisation = enabled;
      home-manager = enabled;
      nix = enabled;
    };
  };

  system.stateVersion = "22.05";

  boot = {
    supportedFilesystems = [ "ntfs" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
      };
    };
  };
}
