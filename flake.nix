{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    maimpick.url = "github:aidenscott2016/larbs-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dwm = { url = "github:aidenscott2016/dwm"; };
    home-manager.url = "github:nix-community/home-manager";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs@{ nixpkgs, nixos-hardware, dwm, home-manager, nixos-generators, ... }:
    {
      nixosConfigurations = {
        # locutus = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = [
        #     ./common/default.nix
        #     ./hosts/lars/configuration.nix
        #     dwm.nixosModules.default
        #     home-manager.nixosModules.home-manager
        #     {
        #       home-manager.useGlobalPkgs = true;
        #       home-manager.useUserPackages = true;
        #       home-manager.users.aiden = import ./home/home.nix;

        #     }
        #   ];
        # };
        lars = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./hosts/lars/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x220
            dwm.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aiden = import ./home/home.nix;

            }
          ];
          specialArgs = inputs;
        };
      };
      installer = nixos-generators.nixosGenerate
        {
          system = "x86_64-linux";
          format = "install-iso";
          modules = [{
            networking.networkmanager.enable = true;
            users.extraUsers.root.openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDirRxg3cezRMK8eTOUbz1K2ilbrui705FxowZa22F+e8nEo7MxpMO3Q+xwmHmXadBgdxdSUc4WOM6c2naNvBFmH7Zh6jXJ8Wt/bgkgSBzOWZ/LU5vBG5wNHXPfIFk/ZM+Q2FU6NL1bN04OPG41c1SuwBKsea6eqQHLDyIz4kfxD2zlXKEtsF3/GpWAxU6bc/H8wWh3M90bPc2a6WJj1T5bml4Zn0EbzQ02ga6Cov7VYG+5+y+IbKcEt5tk326WCLbBRzny0ouo1z7Xen/ldQm1qTVVqoRmzFCmTM66Ozyn8KiIa0vDlKGz/6YapVLAbYR96AeSoOF04HIZp6U90MnP3F40tu2Z8DnD7IO5YWTE6gvDhswpfRSTfDraExbSTN6GIztxr7kXJExop7Mvb9gpyMTteRx6DAg25+QV9MErxoFl4O1WjjpK+FBeQ+Dr7w5SWGjhbA9zZGewfXukpwluqGUmDKlLP/OIxQDsjRl5ZbcWs9wbSIudkRkghOsE14E= aiden@liquid"
            ];
          }];
        };
    };

}  
