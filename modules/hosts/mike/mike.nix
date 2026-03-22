{ inputs, config, ... }:
{
  flake.nixosConfigurations.mike = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_packages.nix
      ./_autorandr/autorandr.nix
      inputs.dwm.nixosModules.default
      inputs.nixos-facter-modules.nixosModules.facter
      inputs.disko.nixosModules.disko
      ./_disk-configuration.nix
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
      inputs.lanzaboote.nixosModules.lanzaboote
    ] ++ (with config.flake.modules.nixos; [
      desktop gaming steam oblivion-sync openttd nvidia virtualisation scanner nix tlp secureboot-vm-testing secureboot
      redshift multimedia
    ]) ++ [
      config.flake.modules.nixos."home-manager"
    ] ++ [
      ({ config, lib, ... }: {
        networking.hostName = "mike";
        system.stateVersion = "22.05";
        nixpkgs.overlays = [ inputs.self.overlays.default ];

        facter.reportPath = ./facter.json;

        boot.initrd.systemd.enable = true;
        hardware.cpu.intel.updateMicrocode = true;

        services.upower.enable = true;
        services.fwupd.enable = true;
        services.throttled.enable = true;
        services.irqbalance.enable = true;

        boot.kernel.sysctl."vm.swappiness" = 10;

        environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

        # Enable thinkpad_acpi fan control so thinkfan can manage the fan
        boot.extraModprobeConfig = ''
          options thinkpad_acpi fan_control=1
        '';

        services.thinkfan = {
          enable = true;
          sensors = [{ type = "tpacpi"; query = "/proc/acpi/ibm/thermal"; }];
          fans = [{ type = "tpacpi"; query = "/proc/acpi/ibm/fan"; }];
          levels = [
            [ 0              0  55 ]
            [ 1             48  60 ]
            [ 2             50  61 ]
            [ 3             52  63 ]
            [ 6             56  65 ]
            [ 7             60  80 ]
            [ "level disengaged" 75 32767 ]
          ];
        };

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

        systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [];
        networking.dhcpcd.enable = false;

        services.upower.criticalPowerAction = "PowerOff";
      })
    ];
  };
}
