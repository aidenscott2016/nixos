params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
with lib;
let
  web-port = 9091;
in
enableableModule "transmission" params {
  services.transmission = {
    user = "aiden";
    openFirewall = true;
    settings = {
      rpc-port = web-port;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      download-dir = "/home/aiden/downloads";
      incomplete-dir = "/home/aiden/downloads/.incomplete";
      alt-speed-up = 500;
      alt-speed-down = 500;
      rpc-host-whitelist-enabled = false;
    };
    enable = true;
  };
  networking.firewall.allowedTCPPorts = [ web-port ];

}
