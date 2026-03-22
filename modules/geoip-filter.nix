{ ... }:
{
  flake.modules.nixos.geoip-filter =
    { lib, pkgs, config, ... }:
    let
      countries = [ "GB" "IM" ];
      countryPattern = lib.concatMapStringsSep " || "
        (c: ''$0 ~ /""iso_code"":""${c}""/'')
        countries;

      geoipNft = pkgs.runCommand "geoip-allowed.nft" {
        nativeBuildInputs = [ pkgs.mmdbctl pkgs.gawk ];
        dbip = pkgs.dbip-country-lite;
      } ''
        mmdbctl export -f csv "$dbip/share/dbip/dbip-country-lite.mmdb" \
          | awk -F, 'NR > 1 && (${countryPattern}) && index($1, ":") == 0 {
              print "  " $1 ","
            }' > cidrs.txt

        count=$(wc -l < cidrs.txt)
        if [ "$count" -lt 100 ]; then
          echo "ERROR: only $count CIDRs extracted, expected hundreds" >&2
          exit 1
        fi

        {
          printf 'define geoip_cidrs = {\n'
          sed '$ s/,$//' cidrs.txt
          printf '}\n'
        } > $out
      '';

      wanInterface = config.aiden.modules.router.externalInterface;
    in
    {
      networking.nftables.tables.geoip = {
        family = "ip";
        content = ''
          include "${geoipNft}"

          set allowed {
            type ipv4_addr
            flags interval
            elements = $geoip_cidrs
          }

          chain filter {
            type filter hook input priority -10; policy accept;
            iifname "${wanInterface}" ip saddr != @allowed limit rate 10/second log prefix "geoip-drop: " counter drop
            iifname "${wanInterface}" ip saddr != @allowed counter drop
          }
        '';
      };

      networking.nftables.preCheckRuleset = ''
        sed -i 's|include "${geoipNft}"|define geoip_cidrs = \{ 0.0.0.0/0 \}|' ruleset.conf
      '';
    };
}
