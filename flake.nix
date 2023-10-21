{
  description = "An example NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/release-23.05"; # 
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    nur.url = "github:nix-community/NUR";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    dwm = {
      url = "github:aidenscott2016/dwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      # optionally choose not to download darwin deps (saves some resources on Linux)
      inputs.darwin.follows = "";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, dwm, home-manager
    , nixos-generators, disko, agenix, ... }:
    let
      # you can just move this in to a file
      home-manager-config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.aiden = import ./home/home.nix;
        home-manager.extraSpecialArgs = inputs;
      };
      myModulesPath = builtins.toString ./modules;
    in {
      };
      diskoConfigurations = { locutus = import ./hosts/locutus/disko.nix; };
      nixosConfigurations = {
        locutus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/locutus/configuration.nix
            dwm.nixosModules.default
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            home-manager-config
            nixos-hardware.nixosModules.lenovo-thinkpad-t495 # the t495 is practically identical
            agenix.nixosModules.default
          ];
          specialArgs = inputs // { inherit myModulesPath; };
        };

        #nix build .#nixosConfigurations.lovelace.config.formats.sd-aarch64
        lovelace = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./common/default.nix
            ./hosts/lovelace.nix
            agenix.nixosModules.default
            nixos-generators.nixosModules.all-formats
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/desktop/configuration.nix ./common/default.nix ];
          specialArgs = inputs;
        };
      };
    };
}
