{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs: {
    nixosConfigurations = {

      lars = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/lars/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
