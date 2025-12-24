{
  aiden.tailscale.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.tailscale;
    in
    {
      options.aiden.aspects.tailscale = {
        authKeyPath = mkOption {
          type = types.str;
          description = "Path to tailscale auth key file";
        };
        advertiseRoutes = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to advertise routes (10.0.0.0/22)";
        };
      };

      config = {
        services.tailscale = {
          enable = true;
          openFirewall = true;
        };

        systemd.services.tailscale-autoconnect = {
          description = "Automatic connection to Tailscale";

          # make sure tailscale is running before trying to connect to tailscale
          after = [ "network-pre.target" "tailscale.service" ];
          wants = [ "network-pre.target" "tailscale.service" ];
          wantedBy = [ "multi-user.target" ];

          # set this service as a oneshot job
          serviceConfig.Type = "oneshot";

          # have the job run this shell script
          script = with pkgs; ''
            # wait for tailscaled to settle
            sleep 2
            # check if we are already authenticated to tailscale
            status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
            if [ $status = "Running" ]; then # if so, then do nothing
              exit 0
            fi

            # otherwise authenticate with tailscale
            ${tailscale}/bin/tailscale up -authkey file:${cfg.authKeyPath} ${
              optionalString cfg.advertiseRoutes "--advertise-routes=10.0.0.0/22"
            }
          '';
        };
      };
    };
}
