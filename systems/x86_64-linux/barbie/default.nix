# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, ... }:
{
  flake.nixosConfigurations.barbie = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../../../modules/nixos/common/default.nix
      ../../../modules/nixos/ssh/default.nix
      ../../../modules/nixos/locale/default.nix
      ({ config, lib, pkgs, inputs, ... }: {
        imports = [
          inputs.disko.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ./disk-configuration.nix
          ./hardware-configuration.nix
          inputs.nixos-hardware.nixosModules.gpd-pocket-3
        ];

        # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "barbie";
        networking.networkmanager.enable = true;
        # Enable the X11 windowing system.
        services.xserver.enable = true;
        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };

        services.openssh.openFirewall = true;
        services.desktopManager.plasma6.enable = true;

        security.sudo.wheelNeedsPassword = false; # desktop archetype

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
        system.stateVersion = "24.05"; # Did you read the comment?
        environment.systemPackages = [
          pkgs.maliit-keyboard
        ];
      })
    ];
  };
}
