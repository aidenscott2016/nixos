{ ... }:
{
  flake.modules.nixos.router-dhcp =
    { lib, pkgs, config, ... }:
    with lib;
    let
      dnsmasqEnable = config.aiden.modules.router.dnsmasq.enable;
      keaEnable     = config.aiden.modules.router.kea.enable;
    in
    {
      config = mkMerge [

        # ── dnsmasq (legacy) ────────────────────────────────────────────────
        (mkIf dnsmasqEnable {
          environment.systemPackages = with pkgs; [ dnsmasq ];
          networking.nameservers = [ "127.0.0.1" ];
          services.resolved.enable = false;
          services.dnsmasq = {
            enable = true;
            settings = {
              address = "/sw1a1aa.uk/10.0.1.1";

              domain = "sw1a1aa.uk,10.0.0.0/16,local";
              server = [
                "127.0.0.2#5354"
              ];
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
        })

        # ── Kea DHCP (replaces dnsmasq) ─────────────────────────────────────
        # kea-dhcp-ddns is configured in router/bind.nix alongside BIND so that
        # both the TSIG key config and the DDNS daemon live in the same module.
        (mkIf keaEnable {
          services.resolved.enable = false;

          services.kea.dhcp4 = {
            enable = true;
            settings = {
              "interfaces-config".interfaces = [ "admin" "lan" "iot" "guest" ];

              "lease-database" = {
                type    = "memfile";
                persist = true;
                name    = "/var/lib/kea/dhcp4.leases";
              };

              "valid-lifetime" = 43200; # 12 hours

              "subnet4" = [
                {
                  id     = 1;
                  subnet = "10.0.0.0/24";
                  pools  = [ { pool = "10.0.0.200 - 10.0.0.250"; } ];
                  "option-data" = [
                    { name = "routers";            data = "10.0.0.1"; }
                    { name = "domain-name-servers"; data = "10.0.0.1"; }
                    { name = "domain-name";         data = "sw1a1aa.uk"; }
                  ];
                }
                {
                  id     = 2;
                  subnet = "10.0.1.0/24";
                  pools  = [ { pool = "10.0.1.200 - 10.0.1.250"; } ];
                  "option-data" = [
                    { name = "routers";            data = "10.0.1.1"; }
                    { name = "domain-name-servers"; data = "10.0.1.1"; }
                    { name = "domain-name";         data = "sw1a1aa.uk"; }
                  ];
                }
                {
                  id     = 3;
                  subnet = "10.0.2.0/24";
                  pools  = [ { pool = "10.0.2.200 - 10.0.2.250"; } ];
                  "option-data" = [
                    { name = "routers";            data = "10.0.2.1"; }
                    { name = "domain-name-servers"; data = "10.0.2.1"; }
                    { name = "domain-name";         data = "sw1a1aa.uk"; }
                  ];
                }
                {
                  id     = 4;
                  subnet = "10.0.3.0/24";
                  pools  = [ { pool = "10.0.3.200 - 10.0.3.250"; } ];
                  "option-data" = [
                    { name = "routers";            data = "10.0.3.1"; }
                    { name = "domain-name-servers"; data = "10.0.3.1"; }
                    { name = "domain-name";         data = "sw1a1aa.uk"; }
                  ];
                }
              ];

              # Tell kea-dhcp4 to forward DDNS update requests to kea-dhcp-ddns.
              "dhcp-ddns" = {
                "enable-updates" = true;
                "server-ip"      = "127.0.0.1";
                "server-port"    = 53001; # kea-dhcp-ddns default listening port
                "ncr-protocol"   = "UDP";
              };

              "ddns-send-updates"       = true;
              "ddns-qualifying-suffix"  = "sw1a1aa.uk";
              "ddns-override-client-update" = true;
              "ddns-update-on-renew"    = true;
            };
          };
        })

      ];
    };
}
