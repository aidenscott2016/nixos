{ inputs, config, ... }:
{
  flake.nixosConfigurations.mike = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_packages.nix
      ./_autorandr
      inputs.dwm.nixosModules.default
      inputs.nixos-facter-modules.nixosModules.facter
      inputs.disko.nixosModules.disko
      ./_disk-configuration.nix
    ] ++ (with config.flake.modules.nixos; [
      desktop gaming nvidia virtualisation scanner nix
    ]) ++ [
      config.flake.modules.nixos."home-manager"
    ] ++ [
      ({ config, ... }: {
        networking.hostName = "mike";
        system.stateVersion = "22.05";
        nixpkgs.overlays = [ inputs.self.overlays.default ];

        facter.reportPath = ./facter.json;

        boot.initrd.systemd.enable = true;
        services.upower.enable = true;

        aiden = {
          architecture = {
            cpu = "intel";
            gpu = "nvidia";
          };
          programs.beets.enable = false;
          modules.nvidia = {
            prime = {
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
            };
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
          modules.gaming = {
            games.oblivionSync.enable = true;
            steam.enable = true;
            moonlight.client.enable = true;
          };
        };

        boot.loader.systemd-boot.enable = true;
        boot.kernelParams = [ "resume_offset=264448" ];
        boot.resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";
      })
    ];
  };
}
