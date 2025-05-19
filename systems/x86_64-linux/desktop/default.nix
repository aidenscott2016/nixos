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
    inputs.dwm.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.disko.nixosModules.default
    ./disk-configuration.nix
  ];

  facter.reportPath = ./facter.json;

  networking.interfaces.enp6s0.wakeOnLan.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "aiden";
  };
  aiden = {
    architecture = {
      cpu = "amd";
      gpu = "amd";
    };
    modules = {
      desktop.enable = true;
      desktop.powermanagement.enable = false;
      gaming = {
        games.oblivionSync.enable = true;
        steam.enable = true;
        moonlight.client.enable = true;
        moonlight.server.enable = true;
      };
      virtualisation.enable = true;
      home-manager.enable = true;
      nix.enable = true;
    };
  };

  system.stateVersion = "22.05";

  boot.loader.systemd-boot.enable = true;

}
