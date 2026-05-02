{ inputs, ... }:
{
  flake.modules.nixos.opencode =
    { pkgs, config, ... }:
    {
      nixpkgs.overlays = [
        (final: prev:
          let
            unstable = import inputs.nixpkgs-unstable { system = prev.system; };
            # Unstable's default Bun linux-x64 build targets AVX2; baseline matches CPUs
            # without it (same pattern as bes baseline bun). Bump `hash` when Bun updates.
            bunBaseline = unstable.bun.overrideAttrs (old: {
              src = prev.fetchurl {
                url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
                hash = "sha256-q+NG9jQUVHzfazW3pkmkkMcouT0AYiYVaSORioTA5Zs=";
              };
              sourceRoot = "bun-linux-x64-baseline";
            });
          in
          {
            opencode = unstable.opencode.override { bun = bunBaseline; };
          })
      ];
      environment.systemPackages = [ pkgs.opencode ];

      systemd.services.opencode-web = {
        description = "OpenCode web UI";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = "aiden";
          WorkingDirectory = "/home/aiden/src";
          ExecStart = "${pkgs.opencode}/bin/opencode serve --port 4200 --hostname 127.0.0.1";
          EnvironmentFile = config.age.secrets.opencode-env.path;
          Restart = "always";
          RestartSec = "5s";

          ProtectSystem = "strict";
          ProtectHome = false;
          ReadWritePaths = [
            "/home/aiden/src"
            "/home/aiden/.local"
            "/home/aiden/.config"
          ];
          PrivateTmp = true;
        };
      };

      aiden.modules.reverseProxy.apps = [
        {
          name = "opencode";
          port = 4200;
        }
      ];
    };
}
