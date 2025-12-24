{
  aiden.router.nixos =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.router or { };
      internalInterface = cfg.internalInterface or "enp2s0";
      externalInterface = cfg.externalInterface or "enp1s0";
      dnsmasqEnable = cfg.dnsmasq.enable or false;

      nftRuleset = ''
        define DEV_WAN = ${externalInterface}
        define DEV_LAN = ${internalInterface}
        define WHOLE_LAN = {
          "iot",
          "lan",
          "guest",
          "tailscale0",
          "admin",
          "enp2s0",
        }

        define TRUSTED_LAN = {
          "lan",
          "tailscale0",
          "lo",
          "admin",
          "enp2s0",
        }

        define ALLOWED_INTERNET_GROUP = {
          "lan",
          "tailscale0",
          "guest",
          "admin",
          "enp2s0",
        }

        define DNS_PORTS = {53, 54, 5354, 67}
        define MQTT = 1883

        table ip myfilter {
            chain inbound {
                type filter hook input priority 0; policy drop;
                icmp type echo-request limit rate 1/second accept
                icmp type echo-request drop
                ct state vmap {
                  established : accept,
                  related : accept,
                  invalid : drop
                }

                udp dport  41641 accept comment tailscale

                iifname vmap {
                  lo : accept,
                  $DEV_WAN : jump inbound_world,
                  $WHOLE_LAN : jump inbound_private
               }
            }

            chain inbound_private {
                meta l4proto {tcp, udp} th dport $DNS_PORTS accept
                meta l4proto {tcp, udp} th dport 5601 accept comment iperf

                iifname vmap {
                  $TRUSTED_LAN : jump inbound_private_trusted,
                  iot : jump inbound_private_iot
                }
            }

            chain inbound_private_trusted {
                ip protocol icmp counter accept

                tcp dport {
                  ssh,
                  http,
                  https,
                  $MQTT,
                  8080
                } accept

                tcp dport {9080, 5000-6000 } accept
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

                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $TRUSTED_LAN oifname $WHOLE_LAN  accept

                iifname $ALLOWED_INTERNET_GROUP oifname $DEV_WAN accept
            }

            chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                oifname $DEV_WAN masquerade
            }
        }

        table ip6 myfilter {
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
      '';
    in
    {
      options.aiden.aspects.router = {
        internalInterface = mkOption {
          type = types.str;
          default = "enp2s0";
          description = "Internal network interface";
        };
        externalInterface = mkOption {
          type = types.str;
          default = "enp1s0";
          description = "External network interface";
        };
        dns.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable unbound DNS";
        };
        dnsmasq.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable dnsmasq DHCP/DNS";
        };
      };

      config = mkMerge [
        {
          # Network interfaces with VLANs
          systemd.network.enable = true;
          networking.useNetworkd = true;

          systemd.network = {
            netdevs = {
              "10-bridge0" = {
                netdevConfig = {
                  Name = "bridge0";
                  Kind = "bridge";
                };
              };
              "20-admin" = {
                netdevConfig = {
                  Name = "admin";
                  Kind = "vlan";
                };
                vlanConfig.Id = 100;
              };
              "20-lan" = {
                netdevConfig = {
                  Name = "lan";
                  Kind = "vlan";
                };
                vlanConfig.Id = 101;
              };
              "20-iot" = {
                netdevConfig = {
                  Name = "iot";
                  Kind = "vlan";
                };
                vlanConfig.Id = 102;
              };
              "20-guest" = {
                netdevConfig = {
                  Name = "guest";
                  Kind = "vlan";
                };
                vlanConfig.Id = 103;
              };
            };

            networks = {
              "30-${externalInterface}" = {
                matchConfig.Name = externalInterface;
                networkConfig.DHCP = "yes";
              };
              "30-${internalInterface}" = {
                matchConfig.Name = internalInterface;
                networkConfig.Bridge = "bridge0";
              };
              "30-enp3s0" = {
                matchConfig.Name = "enp3s0";
                networkConfig.Bridge = "bridge0";
              };
              "30-bridge0" = {
                matchConfig.Name = "bridge0";
                address = [ "10.0.4.1/24" ];
                networkConfig.DHCP = "no";
                vlan = [ "lan" "guest" "iot" "admin" ];
                linkConfig.RequiredForOnline = "carrier";
              };
              "40-admin" = {
                matchConfig.Name = "admin";
                address = [ "10.0.0.1/24" ];
                networkConfig.DHCP = "no";
              };
              "40-lan" = {
                matchConfig.Name = "lan";
                address = [ "10.0.1.1/24" ];
                networkConfig.DHCP = "no";
              };
              "40-iot" = {
                matchConfig.Name = "iot";
                address = [ "10.0.2.1/24" ];
                networkConfig.DHCP = "no";
              };
              "40-guest" = {
                matchConfig.Name = "guest";
                address = [ "10.0.3.1/24" ];
                networkConfig.DHCP = "no";
              };
            };
          };

          # Firewall with nftables
          networking.firewall.enable = false;
          networking.nftables = {
            enable = true;
            ruleset = nftRuleset;
          };
        }

        # DHCP/DNS with dnsmasq
        (mkIf dnsmasqEnable {
          environment.systemPackages = with pkgs; [ dnsmasq ];
          networking.nameservers = [ "127.0.0.1" ];
          services.resolved.enable = false;
          services.dnsmasq = {
            enable = true;
            settings = {
              address = "/sw1a1aa.uk/10.0.1.1";
              domain = "sw1a1aa.uk,10.0.0.0/16,local";
              server = [ "127.0.0.2#5354" ];
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
      ];
    };
}
