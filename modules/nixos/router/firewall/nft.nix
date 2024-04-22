{internalInterface, externalInterface}: ''
define DEV_WAN = ${externalInterface}
define DEV_LAN = ${internalInterface}
define WHOLE_LAN = { "iot", "lan", "guest", "tailscale0" }
define TRUSTED_LAN = { "lan", "tailscale0", "lo"}
define ALLOWED_INTERNET_GROUP = { "lan", "tailscale0", "guest" }
define DNS_PORTS = {53, 54, 5354, 67} 
define MQTT = 1883

table ip filter {
    chain inbound {
        type filter hook input priority 0; policy drop;
        icmp type echo-request limit rate 1/second accept
        icmp type echo-request drop
        ct state vmap { established : accept, related : accept, invalid : drop }

        iifname vmap {lo : accept, $DEV_WAN : jump inbound_world, $WHOLE_LAN : jump inbound_private}
    }
    chain inbound_private{
        meta l4proto {tcp, udp} th dport $DNS_PORTS accept

        iifname vmap { $TRUSTED_LAN : jump inbound_private_trusted, iot : jump inbound_private_iot}
    }

    chain inbound_private_trusted {
        ip protocol icmp counter accept 

        tcp dport { ssh, http, https, $MQTT} accept 

        tcp dport {9080 } accept comment pxe
        udp dport {67, 69, 4011 } accept comment pxe
    }

    chain inbound_private_iot {
        tcp dport {$MQTT} accept
    }

    chain inbound_world {
        icmp type echo-request limit rate 5/second accept
    }




    chain forward {
        type filter hook forward priority 0; policy drop;
        ip protocol icmp counter accept comment "accept all ICMP types"
	ip saddr "10.0.1.218" ip daddr "10.0.2.209" meta nftrace set 1

        # Allow traffic from established and related packets, drop invalid
        ct state vmap { established : accept, related : accept, invalid : drop } 

        iifname $TRUSTED_LAN oifname $WHOLE_LAN  accept 

        iifname $ALLOWED_INTERNET_GROUP oifname $DEV_WAN accept 

    }

    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname $DEV_WAN masquerade
    }

}

table ip6 filter {
    chain input {
        type filter hook input priority 0; policy drop;
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain out {
        type filter hook output priority 0; policy drop;
    }
}
''
