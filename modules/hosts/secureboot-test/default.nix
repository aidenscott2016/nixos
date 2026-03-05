{ inputs, config, ... }:
{
  flake.nixosConfigurations.secureboot-test = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.lanzaboote.nixosModules.lanzaboote
      config.flake.modules.nixos.secureboot
      ({ ... }: {
        boot.loader.efi.canTouchEfiVariables = true;
        boot.initrd.systemd.enable = true;

        boot.initrd.luks.devices.cryptroot.device = "/dev/vda2";
        fileSystems."/" = { device = "/dev/mapper/cryptroot"; fsType = "ext4"; };
        fileSystems."/boot" = { device = "/dev/vda1"; fsType = "vfat"; };

        users.users.root.initialPassword = "test";
        system.stateVersion = "25.11";
      })
    ];
  };
}
