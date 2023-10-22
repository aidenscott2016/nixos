inputs:
let
  myModulesPath = builtins.toString ../modules;
  home-manager = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.aiden = import ../home/home.nix;
    home-manager.extraSpecialArgs = inputs;
  };
in {

  locutus = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../common/default.nix
      ./locutus/configuration.nix
      inputs.dwm.nixosModules.default
      inputs.disko.nixosModules.disko
      home-manager
      inputs.home-manager.nixosModules.home-manager
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495 # the t495 is practically identical
      inputs.agenix.nixosModules.default
    ];
    specialArgs = inputs // { inherit myModulesPath; };
  };

  #nix build .#nixosConfigurations.lovelace.config.formats.sd-aarch64
  lovelace = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ../common/default.nix
      ./lovelace.nix
      inputs.agenix.nixosModules.default
      inputs.nixos-generators.nixosModules.all-formats
    ];
  };
  desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./desktop/configuration.nix ../common/default.nix ];
    specialArgs = inputs;
  };
}
