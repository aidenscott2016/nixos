{ inputs, config, ... }:
{
  flake.nixosConfigurations.barbie = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      ./_disk-configuration.nix
      ./_hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.gpd-pocket-3
      inputs.home-manager.nixosModules.home-manager
    ] ++ (with config.flake.modules.nixos; [
      common ssh locale
    ]) ++ [
      ({ pkgs, ... }: {
        networking.hostName = "barbie";
        system.stateVersion = "24.05";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.networkmanager.enable = true;

        services.xserver.enable = true;
        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };
        services.openssh.openFirewall = true;
        services.desktopManager.plasma6.enable = true;

        security.sudo.wheelNeedsPassword = false;

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.aiden = { };

        environment.systemPackages = [ pkgs.maliit-keyboard ];
      })
    ];
  };
}
