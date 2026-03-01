{ ... }:
{
  flake.modules.nixos.tailscale =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.modules.tailscale;
    in
    {
      options.aiden.modules.tailscale = {
        enable = mkEnableOption "";
        advertiseRoutes = mkEnableOption "";
        authKeyPath = mkOption { type = types.str; };
      };

      config = mkIf cfg.enable {
        services = {
          tailscale = {
            enable = true;
            openFirewall = true;
          };
        };
        systemd.services.tailscale-autoconnect = {
          description = "Automatic connection to Tailscale";

          after = [
            "network-pre.target"
            "tailscale.service"
          ];
          wants = [
            "network-pre.target"
            "tailscale.service"
          ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig.Type = "oneshot";

          script = with pkgs; ''
            # wait for tailscaled to settle
            sleep 2
            # check if we are already authenticated to tailscale
            status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
            if [ $status = "Running" ]; then # if so, then do nothing
              exit 0
            fi

            # otherwise authenticate with tailscale
            ${tailscale}/bin/tailscale up -authkey  file:${cfg.authKeyPath} ${strings.optionalString cfg.advertiseRoutes "--advertise-routes=10.0.0.0/22"}
          '';
        };
      };
    };
}
