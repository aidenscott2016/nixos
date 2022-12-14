{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    maimpick = { url = "github:aidenscott2016/larbs-flake"; };
  };

  outputs = inputs: {
    nixosConfigurations = {

      lars = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/lars/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
