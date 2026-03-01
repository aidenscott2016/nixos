{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.beetcamp = pkgs.callPackage ./package.nix { };
  };
}
