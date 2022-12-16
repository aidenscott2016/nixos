{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = { url = "github:aidenscott2016/dwm"; flake = false; };
  };

  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, maimpick, ... }:
    let
      my-dwm = (self: super: {
        dwm = super.dwm.overrideAttrs (_: {
          src = dwm;
        });
      });
    in
    {
      nixosConfigurations = {

        lars = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x220
            { nixpkgs.overlays = [ my-dwm ]; }
          ];
          specialArgs = { maimpick = inputs.maimpick; };
        };
      };
    };
}
