{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = { url = "github:aidenscott2016/dwm"; };
  };

  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, maimpick, ... }:
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
          specialArgs = { maimpick = inputs.maimpick; };
        };
      };
    };
}
