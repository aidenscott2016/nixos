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
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
    ] ++ (with config.flake.modules.nixos; [
      desktop gaming steam oblivion-sync openttd nvidia virtualisation scanner nix tlp
    ]) ++ [
      config.flake.modules.nixos."home-manager"
    ] ++ [
      ({ config, ... }: {
        networking.hostName = "mike";
        system.stateVersion = "22.05";
        nixpkgs.overlays = [ inputs.self.overlays.default ];

        facter.reportPath = ./facter.json;

        boot.initrd.systemd.enable = true;
        hardware.cpu.intel.updateMicrocode = true;

        services.upower.enable = true;
        services.fwupd.enable = true;
        services.thermald.enable = true;
        services.throttled.enable = true;

        aiden = {
          architecture = {
            cpu = "intel";
            gpu = "nvidia";
          };
          modules.nvidia = {
            prime = {
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
            };
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
          modules.gaming = {
            moonlight.client.enable = true;
          };
        };

        boot.loader.systemd-boot.enable = true;
        boot.kernelParams = [ "resume_offset=264448" ];
        boot.resumeDevice = "/dev/disk/by-uuid/ab7e09ed-d079-4ae1-95c5-8a295b40fe82";

        # i7-8650U is a 4-core/8-thread mobile chip — cap nix builds so
        # the UI stays responsive when building alongside the desktop.
        nix.settings.max-jobs = 2;
        nix.settings.cores = 2;
        nix.daemonCPUSchedPolicy = "idle";
        nix.daemonIOSchedClass = "idle";
      })
    ];
  };
}
