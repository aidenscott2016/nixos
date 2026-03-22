{ inputs, config, ... }:
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_packages.nix
      inputs.nixos-facter-modules.nixosModules.facter
      inputs.disko.nixosModules.disko
      ./_disk-configuration.nix
      inputs.lanzaboote.nixosModules.lanzaboote
    ] ++ (with config.flake.modules.nixos; [
      jovian desktop gaming steam oblivion-sync virtualisation nix
      secureboot
    ]) ++ [
      config.flake.modules.nixos."initrd-ssh"
      config.flake.modules.nixos."home-manager"
    ] ++ [
      ({ config, lib, ... }: {
        networking.hostName = "desktop";
        system.stateVersion = "22.05";
        nixpkgs.overlays = [ inputs.self.overlays.default ];

        facter.reportPath = ./facter.json;

        networking.interfaces.enp6s0.wakeOnLan.enable = true;

        services.xserver.enable = lib.mkForce false;
        services.open-webui = {
          enable = true;
          openFirewall = true;
          host = "0";
        };
        services.ollama = {
          enable = true;
          openFirewall = true;
          host = "0";
        };

        aiden = {
          architecture = {
            cpu = "amd";
            gpu = "amd";
          };
          modules = {
            gaming = {
              moonlight.client.enable = true;
              moonlight.server.enable = true;
            };
          };
        };

        boot.loader.systemd-boot.enable = true;

        boot.initrd = {
          availableKernelModules = [ "r8169" ];
          systemd.network.networks."10-ethernet" = {
            matchConfig.Name = "enp6s0";
            networkConfig.DHCP = "yes";
          };
          network.ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_key" ];
        };
      })
    ];
  };
}
