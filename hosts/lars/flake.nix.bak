{
  description = "NixOS configuration with flakes";
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.lars = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-hardware.nixosModules.lenovo-thinkpad-x220
        ./configuration.nix
      ];
    };
  };
}
