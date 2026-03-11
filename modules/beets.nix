{ inputs, ... }:
{
  flake.modules.nixos.beets =
    { pkgs, ... }:
    let
      copyartifacts = pkgs.python3.pkgs.beets-copyartifacts.overridePythonAttrs {
        version = "0.1.6";
        src = pkgs.fetchFromGitHub {
          owner = "adammillerio";
          repo = "beets-copyartifacts";
          tag = "v0.1.6";
          hash = "sha256-fMnXuMwxylO9Q7EFPpkgwwNeBuviUa8HduRrqrqdMaI=";
        };
        doCheck = false;
        meta.broken = false;
      };
    in
    {
      environment.systemPackages = [
        (pkgs.python3.pkgs.toPythonApplication (pkgs.python3.pkgs.beets.override {
          pluginOverrides = {
            fetchart.enable = true;
            discogs.enable = true;
            bandcamp = {
              enable = true;
              propagatedBuildInputs = [ inputs.self.packages.x86_64-linux.beetcamp ];
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
