{
  description = "An example NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/release-23.05"; # 
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = {
      url = "github:aidenscott2016/dwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager/release-23.05";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  };

  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, home-manager
    , nixos-generators, disko, ... }:
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
          ];
          specialArgs = inputs // { inherit myModulesPath; };
        };
        lars = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x220
            dwm.nixosModules.default
            home-manager.nixosModules.home-manager
            home-manager-config
          ];
          specialArgs = inputs;
        };
        gila = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/gila/configuration.nix
            home-manager.nixosModules.home-manager
            home-manager-config
            disko.nixosModules.disko
          ];
          specialArgs = inputs;
        };
        gila = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/gila/configuration.nix
            home-manager.nixosModules.home-manager
            home-manager-config
            disko.nixosModules.disko
          ];
          specialArgs = inputs;
        };
      };
      };

      installer = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        modules = [
          ./common
          home-manager.nixosModules.home-manager
          {

            services.logind.extraConfig = "HandleLidSwitch=ignore";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import ./home/home.nix;
            networking.networkmanager.enable = true;
            networking.wireless.enable = false;
            users.extraUsers.nixos.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars"
            ];

          }

        ];
      };
    };
}
