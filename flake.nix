{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = { url = "github:aidenscott2016/dwm"; };
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, maimpick, home-manager, ... }:
    {
      nixosConfigurations = {
        locutus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x
            dwm.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aiden = import ./home/home.nix;

            }
          ];
          specialArgs = { maimpick = inputs.maimpick; /*i think maimpick should be made in to a module?*/ };
        };
        lars = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x220
            dwm.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aiden = import ./home/home.nix;

            }
          ];
          specialArgs = { maimpick = inputs.maimpick; /*i think maimpick should be made in to a module?*/ };
        };
      };
    };
}
