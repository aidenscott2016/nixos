{ inputs, ... }:
{
  flake.modules.nixos.beets =
    { pkgs, ... }:
    let
      beet-override =
        with pkgs;
        (beets.override {
          pluginOverrides = {
            fetchart.enable = true;
            bandcamp = {
              enable = true;
              propagatedBuildInputs = [ inputs.self.packages.x86_64-linux.beetcamp ];
            };
            discogs.enable = true;
            copyartifacts = {
              enable = true;
              propagatedBuildInputs = [ beetsPackages.copyartifacts ];
            };
          };
        });
    in
    {
      config = {
        environment.systemPackages = [ beet-override ];
      };
    };
}
