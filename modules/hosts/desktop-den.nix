{ aiden, inputs, ... }:
{
  # Register desktop-den host
  den.hosts.x86_64-linux.desktop-den.users.aiden = { };

  # Define desktop-den host aspect
  den.aspects.desktop-den = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.desktop
      aiden.jovian
      aiden.gaming
      aiden.steam
      aiden.oblivion-sync
      aiden.virtualisation
      aiden.home-manager
    ];

    nixos =
      { pkgs, lib, config, ... }:
      {
        imports = [
          ./systems/x86_64-linux/desktop/disk-configuration.nix
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.default
        ];

        facter.reportPath = ./systems/x86_64-linux/desktop/facter.json;

        # Set architecture options
        aiden.aspects.architecture = {
          cpu = "amd";
          gpu = "amd";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "desktop.sw1a1aa.uk";
          email = "aiden@desktop.sw1a1aa.uk";
        };

        # Set gaming options
        aiden.aspects.gaming = {
          steam.enable = true;
          moonlight.client.enable = true;
          moonlight.server.enable = true;
          oblivionSync.enable = true;
        };

        # Set desktop power management off
        aiden.aspects.desktop.powermanagement.enable = false;

        # Networking
        networking.interfaces.enp6s0.wakeOnLan.enable = true;

        # Override xserver from desktop aspect
        services.xserver.enable = lib.mkForce false;

        # AI services
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

        # Boot
        boot.loader.systemd-boot.enable = true;
        boot.kernelParams = [ "ip=dhcp" ];
        boot.initrd = {
          availableKernelModules = [ "r8169" ];
          network = {
            enable = true;
            ssh = {
              enable = true;
              port = 22;
              authorizedKeys = [ config.aiden.aspects.common.publicKey ];
              hostKeys = [ "/etc/secrets/initrd/ssh_host_key" ];
              shell = "/bin/cryptsetup-askpass";
            };
          };
        };

        system.stateVersion = "22.05";
      };
  };
}
