{
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cachix.cachix.org"
      "https://nixpkgs.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.flox.dev"
    ];
    trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "cache.nixos.org-1:6NCHdD59X431o0mWqyPMV+FnfCelaCYkFdeVX6Ht7cg="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-pinned.url = "github:nixos/nixpkgs/36226520e9f7a35bf341cbe3b6a1ff9047bec6d9";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steamtinkerlaunch = {
      flake = false;
      url = "github:sonic2kk/steamtinkerlaunch";
    };
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
      inputs.darwin.follows = "";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-facter.url = "github:nix-community/nixos-facter";
    nixos-images.url = "github:nix-community/nixos-images";
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    switch-fix = {
      url = "github:femtodata/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dendritic pattern dependencies
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
  };

  outputs = inputs@{ self, flake-parts, import-tree, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      # Manually load and collect module definitions from aspects
      aspectFiles = lib.filesystem.listFilesRecursive ./aspects/features;
      validAspects = builtins.filter
        (path: lib.hasSuffix ".nix" (toString path) && !(lib.hasPrefix "_" (baseNameOf path)))
        aspectFiles;

      # Load each aspect and collect its module contributions
      loadedAspects = map (path: import path { inherit lib inputs; }) validAspects;

      # Collect nixosModules
      nixosModules = lib.foldl' (acc: aspect:
        if aspect ? flake.nixosModules
        then acc // aspect.flake.nixosModules
        else acc
      ) { } loadedAspects;

      # Collect homeManagerModules
      homeManagerModules = lib.foldl' (acc: aspect:
        if aspect ? flake.homeManagerModules
        then acc // aspect.flake.homeManagerModules
        else acc
      ) { } loadedAspects;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./aspects/_lib.nix ];
      systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = {
        # Expose collected modules
        inherit nixosModules homeManagerModules;

        # Helper to create nixosSystem with all modules
        lib.mkHost = name: system: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            # Load all feature modules
            (builtins.attrValues nixosModules)
            # Load existing host config from systems/
            ./systems/${if system == "aarch64-linux" then "aarch64-linux" else if name == "installer" then "x86_64-install-iso" else "x86_64-linux"}/${name}
            # Home-manager integration
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = builtins.attrValues homeManagerModules;
            }
          ];
        };

        # Define all nixosConfigurations
        nixosConfigurations = with self.lib; {
          locutus = mkHost "locutus" "x86_64-linux";
          mike = mkHost "mike" "x86_64-linux";
          desktop = mkHost "desktop" "x86_64-linux";
          gila = mkHost "gila" "x86_64-linux";
          thoth = mkHost "thoth" "x86_64-linux";
          bes = mkHost "bes" "x86_64-linux";
          tv = mkHost "tv" "x86_64-linux";
          barbie = mkHost "barbie" "x86_64-linux";
          pxe = mkHost "pxe" "x86_64-linux";
          lovelace = mkHost "lovelace" "aarch64-linux";
          installer = mkHost "installer" "x86_64-linux";
        };
      };

      # Per-system outputs
      perSystem = { config, system, pkgs, ... }: {
        # Keep existing packages
        packages = import ./packages { inherit pkgs; };
      };
    };
}
