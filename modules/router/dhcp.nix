{ ... }:
{
  flake.modules.nixos.router-dhcp =
    { lib, pkgs, config, ... }:
    with lib;
    let
      dnsmasqEnable = config.aiden.modules.router.dnsmasq.enable;
    in
    {
      config = mkIf dnsmasqEnable {
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
              "set:work,10.0.5.200,10.0.5.250,255.255.255.0,12h"
            ];
            dhcp-host = [
              "3c:6d:66:4c:fa:b6,shield,10.0.1.215"
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

              "tag:work,option:router,10.0.5.1"
              "tag:work,option:dns-server,10.0.5.1"
            ];
          };
        };
      };
    };
}
