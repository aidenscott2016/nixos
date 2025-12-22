{ lib, ... }:
{
  flake.nixosModules.nix = { config, lib, pkgs, inputs, ... }:
    with lib;
    let cfg = config.aiden.modules.nix;
    in {
      options.aiden.modules.nix.enable = mkEnableOption "nix tools and configuration";

      config = mkIf cfg.enable {
        programs = {
          nh.enable = true;
        };

        nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        nix.extraOptions = "experimental-features = nix-command flakes";
        nix.settings.auto-optimise-store = true;
        nix.settings.trusted-users = [ "aiden" ];

        environment.systemPackages = with pkgs; [
          nixpkgs-fmt
          nix-tree
          inputs.disko.packages.x86_64-linux.disko
        ];



        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };

        # Enable binary cache
        nix.settings = {
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://cache.flox.dev"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0mWqyPMV+FnfCelaCYkFdeVX6Ht7cg="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
          ];
        };
      };
    };
}
