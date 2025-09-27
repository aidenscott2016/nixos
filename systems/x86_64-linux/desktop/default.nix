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
    #inputs.dwm.nixosModules.default #
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.disko.nixosModules.default
    ./disk-configuration.nix
  ];

  facter.reportPath = ./facter.json;

  networking.interfaces.enp6s0.wakeOnLan.enable = true;

  services.xserver.enable = lib.mkForce false;
  aiden = {
    architecture = {
      cpu = "amd";
      gpu = "amd";
    };
    programs.beets.enable = lib.mkForce false;
    modules = {
      redshift.enable = lib.mkForce false;
      hardware-acceleration.enable = lib.mkForce true;
      jovian.enable = true;
      desktop.enable = true;
      desktop.powermanagement.enable = false;
      gaming = {
        games.oblivionSync.enable = true;
        steam.enable = false;
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

  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd = {
    availableKernelModules = [ "r8169" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ config.aiden.modules.common.publicKey ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_key" ];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };

}
