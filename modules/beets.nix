{ inputs, ... }:
{
  flake.modules.nixos.beets =
    { pkgs, ... }:
    let
      unstablePkgs = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
      };
      py3 = unstablePkgs.python3.pkgs;

      beetcamp = unstablePkgs.callPackage "${inputs.self}/modules/beetcamp/_package.nix" { };

      copyartifacts = py3.beets-copyartifacts.overridePythonAttrs {
        doCheck = false;
        meta.broken = false;
      };
    in
    {
      environment.systemPackages = [
        pkgs.chromaprint
        (py3.toPythonApplication (py3.beets.override {
          pluginOverrides = {
            fetchart.enable = true;
            discogs.enable = true;
            chroma.enable = true;
            bandcamp = {
              enable = true;
              propagatedBuildInputs = [ beetcamp ];
            };
            copyartifacts = {
              enable = true;
              propagatedBuildInputs = [ copyartifacts ];
            };
          };
        }))
      ];
    };
}
