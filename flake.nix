{
  description = "An example NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
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
      # optionally choose not to download darwin deps (saves some resources on Linux)
      inputs.darwin.follows = "";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-facter.url = "github:nix-community/nixos-facter";
    nixos-images.url = "github:nix-community/nixos-images";
  };
  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall = {
        namespace = "aiden";
      };
      diskoConfigurations = {
        locutus = import ./hosts/locutus/disko.nix;
      };
      channels-config = {
        packageOverrides = pkgs: { firefox-addons = inputs.firefox-addons { inherit pkgs; }; };
        nvidia.acceptLicense = true;
        allowUnfree = true;
        config.permittedInsecurePackages = [
          "aspnetcore-runtime-wrapped-6.0.36"
          "aspnetcore-runtime-6.0.36"
        ];

      };
    };
}
