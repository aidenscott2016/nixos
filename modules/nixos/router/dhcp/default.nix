{ config, lib, pkgs, ... }:
with lib;
let
  dnsmasqEnabled = config.aiden.modules.router.dnsmasq.enabled;
in
{
  config = mkIf dnsmasqEnabled {
    environment.systemPackages = with pkgs; [ dnsmasq ];
    networking.nameservers = [ "127.0.0.1" ];
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        address="/sw1a1aa.uk/10.0.1.1";

        domain = "sw1a1aa.uk,10.0.0.0/16,local";
        # upstream DNS
        server = [
          "10.0.0.1#5354" #adguard
        ];
        no-resolv = true;
        bogus-priv = true;
        domain-needed = true;
        expand-hosts = true;
        dhcp-range = [
          "set:lan,10.0.1.200,10.0.1.250,255.255.255.0,12h"
          "set:iot,10.0.2.200,10.0.2.250,255.255.255.0,12h"
          "set:guest,10.0.3.200,10.0.3.250,255.255.255.0,12h"
          "set:eth3,10.0.4.2,10.0.4.255,255.255.255.0,12h"

        ];
        dhcp-option = [
          "tag:lan,option:router,10.0.1.1"
          "tag:lan,option:dns-server,10.0.1.1"

          "tag:iot,option:router,10.0.2.1"
          "tag:iot,option:dns-server,10.0.2.1"

          "tag:guest,option:router,10.0.3.1"
          "tag:guest,option:dns-server,10.0.3.1"

          "tag:eth3,option:router,10.0.4.1"
          "tag:eth3,option:dns-server,10.0.4.1"
        ];
      };
    };
  };
}
