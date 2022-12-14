{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs: {
    nixosConfigurations = with inputs; {

      lars = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/lars/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x220
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
