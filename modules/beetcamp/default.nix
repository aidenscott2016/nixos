{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.beetcamp = pkgs.callPackage ./_package.nix { };
  };
}
