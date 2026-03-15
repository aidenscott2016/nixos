{ inputs, ... }:
{
  flake.modules.nixos.uptime-kuma =
    { ... }:
    {
      disabledModules = [ "services/monitoring/uptime-kuma.nix" ];

      imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/monitoring/uptime-kuma.nix" ];

      nixpkgs.overlays = [
        (final: prev:
          let
            unstable = import inputs.nixpkgs-unstable { system = prev.system; };
          in
          {
            inherit (unstable) uptime-kuma;
          })
      ];

      services.uptime-kuma = {
        enable = true;
        settings.PORT = "3001";
      };

      aiden.modules.reverseProxy.apps = [
        { name = "status"; port = 3001; }
      ];
    };

  perSystem =
    { pkgs, system, ... }:
    let
      domain = "sw1a1aa.uk";
      monitors = [
        { name = "photos";    path = "/api/server/ping"; }
        { name = "sonarr";    path = "/ping"; }
        { name = "radarr";    path = "/ping"; }
        { name = "jellyfin";  path = "/health"; }
        { name = "slskd";     path = "/health"; }
        { name = "grafana";   path = "/api/health"; }
        { name = "portainer"; path = "/api/status"; }
        { name = "sab";       path = "/api?mode=version&output=json"; }
        { name = "bazarr";    path = "/"; }
        { name = "deluge";    path = "/"; }
        { name = "navidrome"; path = "/"; }
        { name = "paperless"; path = "/"; }
        { name = "status";    path = "/"; }
      ];

      terraformConfig = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          {
            terraform.required_providers.uptimekuma = {
              source = "breml/uptimekuma";
              version = "~> 0.1";
            };

            provider.uptimekuma = {
              endpoint = "https://status.${domain}";
              username = "admin";
              password = "\${var.uptime_kuma_password}";
            };

            variable.uptime_kuma_password = {
              type = "string";
              sensitive = true;
            };

            resource.uptimekuma_monitor_http = builtins.listToAttrs (
              map (m: {
                name = m.name;
                value = {
                  name = m.name;
                  url = "https://${m.name}.${domain}${m.path}";
                  interval = 60;
                  max_retries = 3;
                  accepted_status_codes = [ "200-399" ];
                };
              }) monitors
            );

            resource.uptimekuma_settings.main = {
              keep_data_period_days = 90;
              check_update = false;
            };
          }
        ];
      };

      tofu = pkgs.opentofu;
      stateDir = "$HOME/.local/state/uptime-kuma";
    in
    {
      apps.uptime-kuma-apply = {
        type = "app";
        program = toString (pkgs.writers.writeBash "uptime-kuma-apply" ''
          set -euo pipefail
          mkdir -p "${stateDir}"
          cd "${stateDir}"
          install -m 644 ${terraformConfig} config.tf.json
          ${tofu}/bin/tofu init -upgrade
          ${tofu}/bin/tofu apply -auto-approve
        '');
      };

      apps.uptime-kuma-destroy = {
        type = "app";
        program = toString (pkgs.writers.writeBash "uptime-kuma-destroy" ''
          set -euo pipefail
          mkdir -p "${stateDir}"
          cd "${stateDir}"
          install -m 644 ${terraformConfig} config.tf.json
          ${tofu}/bin/tofu init
          ${tofu}/bin/tofu destroy
        '');
      };
    };
}
