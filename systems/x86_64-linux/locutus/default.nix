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
      desktop.enable = true;
      gc.enable = true;
      gaming = {
        steam.enable = true;
        moonlight.client.enable = true;
      };
      virtualisation.enable = true;
      home-manager.enable = true;
      nix.enable = true;
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
