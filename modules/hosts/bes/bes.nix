{ inputs, config, ... }:
{
  flake.nixosConfigurations.bes = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_hardware-configuration.nix
      ./_disk-config.nix
      ./_k3s.nix
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
    ]
    ++ (with config.flake.modules.nixos; [
      common
      architecture
      locale
      avahi
      syncthing
      media-storage
      beets
    ])
    ++ [
      config.flake.modules.nixos."cli-base"
    ]
    ++ [
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          networking.hostName = "bes";
          system.stateVersion = "23.11";
          nixpkgs.overlays = [
            inputs.self.overlays.default
            # Pentium J5005 (Gemini Lake) lacks AVX2; use bun baseline binary
            (final: prev: {
              bun = prev.bun.overrideAttrs (old: {
                src = prev.fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${old.version}/bun-linux-x64-baseline.zip";
                  hash = "sha256-EE1NA39LNeECFcBQfhd5aR85xXvZHd7v4RyteB4/xLk=";
                };
                sourceRoot = "bun-linux-x64-baseline";
              });
            })
          ];

          aiden = {
            architecture = {
              cpu = "intel";
              gpu = "intel";
            };
            modules.common.domainName = "bes.sw1a1aa.uk";
          };

          age.secrets.restic-b2-env.file = "${inputs.self.outPath}/secrets/restic-b2-env.age";
          age.secrets.restic-b2-password.file = "${inputs.self.outPath}/secrets/restic-b2-password.age";

          services.restic.backups.b2 = {
            paths = [
              "/media/t7/photos"
              "/srv/media/Music/library/Cocteau Twins/1993 - Four-Calendar Café"
            ];
            repository = "s3:s3.eu-central-003.backblazeb2.com/backup-uwdcrk";
            environmentFile = config.age.secrets.restic-b2-env.path;
            passwordFile = config.age.secrets.restic-b2-password.path;
            initialize = true;
            createWrapper = true;
            timerConfig = {
              OnCalendar = "daily";
              Persistent = "true";
            };
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 6"
              "--keep-yearly 2"
            ];
          };

          programs.mosh.enable = true;

          services.iperf3.enable = true;
          services.iperf3.openFirewall = true;
          services.openssh.enable = true;
          services.openssh.openFirewall = true;
          security.sudo.wheelNeedsPassword = false;
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          services.cockpit.enable = true;
          services.cockpit.openFirewall = true;

          environment.systemPackages = with pkgs; [
            get_iplayer
            wol
            iperf3
            kubectl
            fluxcd
          ];
        }
      )
    ];
  };
}
