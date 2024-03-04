{ config, lib, pkgs, ... }:
with {
  inherit (config.aiden.modules.router)
    enabled internalInterface externalInterface;
}; {
  config = lib.mkIf enabled {
    networking = {
      firewall.enable = false;
      nftables = {
        enable = true;
        ruleset = ''
          table ip filter {
            chain input {
              type filter hook input priority 0; policy drop;
              ip protocol icmp counter accept comment "accept all ICMP types"
              iifname "${externalInterface}" tcp dport { http, https } drop comment "only allow wan traffic to http{,s}"
              iifname {"${internalInterface}", "lan", "eth3", "lo", "iot", "guest", "tailscale0"} accept comment "Allow trusted local network to access the router"
              iifname "${externalInterface}" ct state { established, related } accept comment "Allow established traffic"
              iifname "${externalInterface}" counter drop comment "drop all other unsolicited traffic from wan"
            }

            chain forward {
              type filter hook forward priority 0; policy drop;
              ip protocol icmp counter accept comment "accept all ICMP types"
              iifname { "${internalInterface}", "lan", "guest", "eth3"} oifname { "${externalInterface}" } accept comment "Allow LAN to WAN"
              iifname "lan" oifname "iot" accept comment "Allow lan to iot"
              iifname "iot" oifname "lan" ct state { established, related } accept comment "Allow established from iot back to lan"
              iifname { "${externalInterface}" } oifname { "${internalInterface}", "lan", "eth3", "guest"} ct state { established, related } accept comment "Allow established back to LANs"
            }


          }

          table ip nat {
            chain postrouting {
              type nat hook postrouting priority 100; policy accept;
              oifname "${externalInterface}" masquerade
            }
          }

          table ip6 filter {
          chain input {
              type filter hook input priority 0; policy drop;
            }
            chain forward {
              type filter hook forward priority 0; policy drop;
            }
          }
        '';
      };
    };
  };
}
