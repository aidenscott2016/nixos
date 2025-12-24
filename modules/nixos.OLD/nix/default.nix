params@{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  moduleName = "nix";
in
{
  options = {
    aiden.modules.nix.enable = mkEnableOption moduleName;
  };

  config = mkIf config.aiden.modules.nix.enable {
    programs = {
      nh.enable = true;
    };

    environment.systemPackages = with pkgs; [
      nixpkgs-fmt
      nix-tree
      inputs.disko.packages.x86_64-linux.disko
    ];

    # Enable garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

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
}
