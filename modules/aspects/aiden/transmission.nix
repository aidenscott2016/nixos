{
  aiden.transmission.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.transmission or { };
      web-port = 9091;
    in
    {
      options.aiden.aspects.transmission = {
        enable = mkEnableOption "Transmission torrent client";
        downloadDir = mkOption {
          type = types.str;
          default = "/home/aiden/downloads";
          description = "Download directory";
        };
      };

      config = mkIf (cfg.enable or false) {
        services.transmission = {
          user = "aiden";
          openFirewall = true;
          settings = {
            rpc-port = web-port;
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist-enabled = false;
            download-dir = cfg.downloadDir;
            incomplete-dir = "${cfg.downloadDir}/.incomplete";
            alt-speed-up = 500;
            alt-speed-down = 500;
            rpc-host-whitelist-enabled = false;
          };
          enable = true;
        };
        networking.firewall.allowedTCPPorts = [ web-port ];
      };
    };
}
