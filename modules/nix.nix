{ inputs, ... }:
{
  flake.modules.nixos.nix =
    { lib, pkgs, config, ... }:
    with lib;
    {
      programs = {
        nh.enable = true;
      };

      environment.systemPackages = with pkgs; [
        nixpkgs-fmt
        nix-tree
        inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
      ];

      nix.settings = {
        substituters = [ "https://cache.flox.dev" ];
        trusted-public-keys = [
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        ];
      };
    };
}
