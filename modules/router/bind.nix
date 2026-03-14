{ ... }:
{
  flake.modules.nixos.router-bind =
    { lib, pkgs, config, ... }:
    with lib;
    let
      enable = config.aiden.modules.router.bind.enable;

      # Seed zone file — BIND manages this file after initial creation via dynamic updates.
      # Only copied if the file doesn't already exist.
      initialZone = pkgs.writeText "sw1a1aa.uk.zone" ''
        $ORIGIN sw1a1aa.uk.
        $TTL 300
        @  IN SOA  ns1.sw1a1aa.uk. hostmaster.sw1a1aa.uk. (
                     2024010101 ; serial
                     3600       ; refresh
                     900        ; retry
                     604800     ; expire
                     300 )      ; minimum TTL
        @  IN NS   ns1.sw1a1aa.uk.
        ns1 IN A   10.0.1.1
        gila IN A  10.0.1.1
      '';

      # kea-dhcp-ddns config template — @TSIG_SECRET@ is substituted at runtime
      # from the age secret so the actual key never lands in the Nix store.
      keaDdnsTemplate = pkgs.writeText "kea-dhcp-ddns-template.json" (builtins.toJSON {
        DhcpDdns = {
          "ip-address" = "127.0.0.1";
          port = 53001;
          "dns-server-timeout" = 500;
          "ncr-protocol" = "UDP";
          "ncr-format" = "JSON";
          "forward-ddns" = {
            "ddns-domains" = [
              {
                name = "sw1a1aa.uk.";
                "key-name" = "ddns-key";
                "dns-servers" = [ { "ip-address" = "127.0.0.1"; port = 5353; } ];
              }
            ];
          };
          "reverse-ddns" = { "ddns-domains" = []; };
          "tsig-keys" = [
            {
              name = "ddns-key";
              algorithm = "HMAC-SHA256";
              secret = "@TSIG_SECRET@";
            }
          ];
        };
      });
    in
    {
      config = mkIf enable {
        systemd.tmpfiles.rules = [
          "d /run/named  0750 named named -"
          "d /run/kea    0755 root  root  -"
        ];

        # Write BIND key config from age secret before named starts.
        # Runs as root (+ prefix) so it can read the age secret and
        # write to /run/named/ before chown to named.
        systemd.services.named = {
          wants = [ "agenix.service" ];
          after = [ "agenix.service" ];
          serviceConfig.ExecStartPre = [
            ("+${pkgs.writeShellScript "prepare-bind-tsig-key" ''
              secret=$(cat ${config.age.secrets.ddnsTsigKey.path})
              printf 'key "ddns-key" {\n  algorithm hmac-sha256;\n  secret "%s";\n};\n' \
                "$secret" > /run/named/ddns-key.conf
              chmod 640 /run/named/ddns-key.conf
              chown named:named /run/named/ddns-key.conf
            ''}")
          ];
        };

        # Seed zone file on first boot — BIND rewrites this file as dynamic updates arrive.
        system.activationScripts.bindZoneInit = {
          text = ''
            if [ ! -f /var/lib/bind/sw1a1aa.uk.zone ]; then
              mkdir -p /var/lib/bind
              cp ${initialZone} /var/lib/bind/sw1a1aa.uk.zone
              chown named:named /var/lib/bind/sw1a1aa.uk.zone
              chmod 644 /var/lib/bind/sw1a1aa.uk.zone
            fi
          '';
          deps = [];
        };

        services.bind = {
          enable = true;
          # Don't listen on default port 53 — AdGuard owns port 53 on the LAN IPs.
          listenOn = [ "none" ];
          listenOnIpv6 = [ "none" ];
          # Authoritative only — no recursion, no forwarding.
          forwarders = [];
          extraOptions = ''
            listen-on port 5353 { 127.0.0.1; };
            recursion no;
          '';
          extraConfig = ''
            include "/run/named/ddns-key.conf";
          '';
          zones."sw1a1aa.uk" = {
            master = true;
            file = "/var/lib/bind/sw1a1aa.uk.zone";
            extraConfig = ''
              allow-query  { 127.0.0.1; 10.0.0.0/16; };
              allow-update { key "ddns-key"; };
            '';
          };
        };

        # kea-dhcp-ddns: substitute TSIG secret at runtime into a copy of the
        # Nix-store template, then start with the runtime config instead.
        systemd.services.kea-dhcp-ddns = {
          wants = [ "agenix.service" ];
          after = [ "agenix.service" ];
          serviceConfig = {
            ExecStartPre = [
              ("+${pkgs.writeShellScript "prepare-kea-ddns-config" ''
                secret=$(cat ${config.age.secrets.ddnsTsigKey.path})
                ${pkgs.gnused}/bin/sed \
                  "s|@TSIG_SECRET@|$secret|g" \
                  ${keaDdnsTemplate} \
                  > /run/kea/dhcp-ddns-runtime.json
                chmod 600 /run/kea/dhcp-ddns-runtime.json
              ''}")
            ];
            ExecStart = lib.mkForce
              "${pkgs.kea}/bin/kea-dhcp-ddns -c /run/kea/dhcp-ddns-runtime.json";
          };
        };

        # Provide a valid (placeholder) configFile so the Kea module's assertion
        # passes — ExecStart is overridden above to use the runtime-generated copy.
        services.kea.dhcp-ddns = {
          enable = true;
          configFile = keaDdnsTemplate;
        };
      };
    };
}
