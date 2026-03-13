{ ... }:
{
  flake.modules.nixos.router-dhcp =
    { lib, pkgs, config, ... }:
    with lib;
    let
      dnsmasqEnable = config.aiden.modules.router.dnsmasq.enable;
      besIP = config.aiden.modules.router.bes.ip;
    in
    {
      config = mkIf dnsmasqEnable {
        environment.systemPackages = with pkgs; [ dnsmasq ];
        networking.nameservers = [ "127.0.0.1" ];
        services.resolved.enable = false;
        services.dnsmasq = {
          enable = true;
          settings = {
            # When bes.ip is set, delegate sw1a1aa.uk to bes's authoritative DNS
            # rather than answering with a catch-all wildcard. Keep a direct
            # address entry for bes.sw1a1aa.uk itself so the delegation target
            # bootstraps even if bes is momentarily unreachable.
          } // (if besIP != null then {
            address = "/bes.sw1a1aa.uk/${besIP}";
            server = [
              "127.0.0.2#5354"
              "/sw1a1aa.uk/${besIP}"
            ];
          } else {
            address = "/sw1a1aa.uk/10.0.1.1";
            server = [
              "127.0.0.2#5354"
            ];
          }) // {
            domain = "sw1a1aa.uk,10.0.0.0/16,local";
            bogus-priv = true;
            domain-needed = true;
            expand-hosts = true;
            dhcp-range = [
              "set:admin,10.0.0.200,10.0.0.250,255.255.255.0,12h"
              "set:lan,10.0.1.200,10.0.1.250,255.255.255.0,12h"
              "set:iot,10.0.2.200,10.0.2.250,255.255.255.0,12h"
              "set:guest,10.0.3.200,10.0.3.250,255.255.255.0,12h"
            ];
            dhcp-option = [
              "tag:admin,option:router,10.0.0.1"
              "tag:admin,option:dns-server,10.0.0.1"

              "tag:lan,option:router,10.0.1.1"
              "tag:lan,option:dns-server,10.0.1.1"

              "tag:iot,option:router,10.0.2.1"
              "tag:iot,option:dns-server,10.0.2.1"

              "tag:guest,option:router,10.0.3.1"
              "tag:guest,option:dns-server,10.0.3.1"
            ];
          };
        };
      };
    };
}
