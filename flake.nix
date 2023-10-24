{
  description = "An example NixOS configuration";
  inputs = {
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
  outputs = inputs:
    let
      mylib = with inputs.lib; {
        optionalModule = name: config: configToEnable:
          let cfg = config.aiden.modules.${name};
          in {
            options.aiden.modules.${name}.enabled = mkOption {
              type = types.bool;
              default = false;
            };
            config = { };
          };
      };

    in {
      diskoConfigurations = { locutus = import ./hosts/locutus/disko.nix; };
      nixosConfigurations = (import ./hosts inputs // mylib);
    };
}
