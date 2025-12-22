{ inputs, config, lib, ... }:
let
  # Helper to create nixosSystem with all modules
  mkHost = name: system: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; self = inputs.self; };
    modules = (builtins.attrValues config.flake.modules.nixos) ++ [
      # Automatically set hostname based on configuration name
      { networking.hostName = name; }
      # Load existing host config from _hosts/
      ./_hosts/${name}
      # Apply channel overlay and allow unfree packages
      {
        nixpkgs.overlays = [ config.flake.overlays.default ];
        nixpkgs.config.allowUnfree = true;
      }
      # Home-manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          sharedModules = builtins.attrValues config.flake.modules.homeManager;
          extraSpecialArgs = { inherit inputs; self = inputs.self; };
        };
      }
      # Pass extended lib with lib.aiden to all modules
      {
        _module.args.lib = lib;
      }
    ];
  };
in
{
  # Define supported systems
  systems = [ "x86_64-linux" "aarch64-linux" ];

  # Define all nixosConfigurations
  flake.nixosConfigurations = {
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

  # Per-system outputs
  perSystem = { config, system, pkgs, ... }: {
    # Keep existing packages
    packages = import ../packages { inherit pkgs; };
  };
}
