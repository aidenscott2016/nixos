{
  description = "A very basic flake";
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;

  outputs = { self, nixpkgs, nixos-hardware }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;
    nixosConfigurations.lars = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-hardware.nixosModules.lenovo-thinkpad-x220
        ./configuration.nix
      ];
    };

  };
}
