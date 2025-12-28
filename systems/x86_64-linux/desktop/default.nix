{ inputs, ... }:
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Desktop sub-modules (manually listed to exclude multimedia and redshift)
      ../../../modules/nixos/syncthing/default.nix
      ../../../modules/nixos/darkman/default.nix
      ../../../modules/nixos/printer/default.nix
      ../../../modules/nixos/emacs/default.nix
      ../../../modules/nixos/thunar/default.nix
      ../../../modules/nixos/locale/default.nix
      ../../../modules/nixos/keyd/default.nix
      ../../../modules/nixos/powermanagement/default.nix
      ../../../modules/nixos/yubikey/default.nix
      ../../../modules/nixos/appimage/default.nix
      ../../../modules/nixos/pipewire/default.nix
      ../../../modules/nixos/ssh/default.nix
      ../../../modules/nixos/avahi/default.nix
      ../../../modules/nixos/common/default.nix
      ../../../modules/nixos/hardware-acceleration/default.nix
      ../../../modules/nixos/ios/default.nix
      ../../../modules/nixos/cli-base/default.nix
      # Other modules
      ../../../modules/nixos/gaming/default.nix
      ../../../modules/nixos/virtualisation/default.nix
      ../../../modules/nixos/jovian/default.nix
      ../../../modules/nixos/nix/default.nix
      ../../../modules/nixos/architecture/default.nix
      ({ config, lib, pkgs, inputs, ... }: {
        imports = [
          ./packages.nix
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.disko.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ./disk-configuration.nix
        ];

        facter.reportPath = ./facter.json;

        networking.hostName = "desktop";
        networking.interfaces.enp6s0.wakeOnLan.enable = true;
        networking.networkmanager.enable = true;

        # Desktop services (from desktop composition module)
        programs.nm-applet.enable = true;
        services = {
          envfs.enable = true;
          blueman.enable = true;
          tailscale.enable = true;
          mullvad-vpn.enable = true;
          gvfs.enable = true;
        };

        systemd.network.wait-online.enable = false;
        hardware.bluetooth.enable = true;

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
            powermanagement.enable = false;
            gaming = {
              games.oblivionSync.enable = true;
              steam.enable = true;
              moonlight.client.enable = true;
              moonlight.server.enable = true;
            };
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

        nixpkgs.config.allowUnfree = true;

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.aiden = {
          imports = [
            ../../../modules/home/bash/default.nix
            ../../../modules/home/darkman/default.nix
            ../../../modules/home/desktop/default.nix
            ../../../modules/home/easyeffects/default.nix
            ../../../modules/home/firefox/default.nix
            ../../../modules/home/git/default.nix
            ../../../modules/home/gpg-agent/default.nix
            ../../../modules/home/ideavim/default.nix
            ../../../modules/home/ssh/default.nix
            ../../../modules/home/tmux/default.nix
            ../../../modules/home/vim/default.nix
            ../../../modules/home/xdg-portal/default.nix
          ];
        };
      })
    ];
  };
}
