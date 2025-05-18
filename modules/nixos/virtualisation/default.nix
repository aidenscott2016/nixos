params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "virtualisation";
in
{
  options = {
    aiden.modules.virtualisation.enable = mkEnableOption moduleName;
  };

  config = mkIf config.aiden.modules.virtualisation.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
      docker-compose
      kubectl
    ];

    programs.virt-manager.enable = true;

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    virtualisation.podman = {
      enable = false;
      dockerSocket.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.libvirtd.enable = true;

    users.groups.libvirtd.members = [ "aiden" ];

    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.vmVariant = {
      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = true;
      virtualisation = {
        memorySize = 2048;
        cores = 3;
      };
    };
  };
}
