{
  config,
  pkgs,
  lib,
  myModulesPath,
  inputs,
  ...
}:
{
  imports = [
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.disko.nixosModules.default
    ./disk-configuration.nix
  ];

  facter.reportPath = ./facter.json;

  aiden = {
    architecture = {
      cpu = "intel";
      gpu = "nvidia";
    };
    modules = {
      desktop.enable = true;
      gaming = {
        games.oblivionSync.enable = true;
        steam.enable = true;
        moonlight.client.enable = true;
      };
      virtualisation.enable = true;
      home-manager.enable = true;
      nix.enable = true;
      nvidia = {
        enable = true;
        prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
  };

  system.stateVersion = "22.05";

  boot.loader.systemd-boot.enable = true;

}
