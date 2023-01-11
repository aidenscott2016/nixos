{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = { url = "github:aidenscott2016/dwm"; };
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, maimpick, home-manager }:
    # let
    #   home-manager-module =
    #     home-manager.nixosModules.home-manager
    #       {
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = true;
    #         home-manager.users.aiden = import ./home/home.nix;

    #       };
    # in
    {
      nixosConfigurations = {
        lars = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x220
            { nixpkgs.overlays = [ dwm.overlays.default ]; }
            dwm.nixosModules.default
          ];
          specialArgs = { maimpick = inputs.maimpick; /*i think maimpick should be made in to a module?*/ };
        };
      };
    };
}
