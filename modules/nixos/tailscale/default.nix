params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
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

      # make sure tailscale is running before trying to connect to tailscale
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
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
        ${tailscale}/bin/tailscale up -authkey  file:${cfg.authKeyPath} ${strings.optionalString cfg.advertiseRoutes "--advertise-routes=10.0.0.0/22"}
      '';
    };
  };
}
