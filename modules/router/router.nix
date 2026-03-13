{ inputs, ... }:
{
  flake.modules.nixos.router =
    { lib, config, ... }:
    with lib;
    with config.aiden.modules.router;
    {
      imports = with inputs.self.modules.nixos; [
        router-dhcp router-dns router-firewall
        router-interfaces router-zeroconf
      ];

      options.aiden.modules.router = {
        internalInterface = mkOption { type = types.str; };
        externalInterface = mkOption { type = types.str; };
        dns.enable = mkEnableOption "unbound dns";
        dnsmasq.enable = mkEnableOption "dnsmasq";
        bes.ip = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Static IP of bes. When set, dnsmasq delegates sw1a1aa.uk DNS
            queries to bes instead of resolving via a wildcard address.
            A direct address entry for bes.sw1a1aa.uk is kept on gila as a
            bootstrap fallback so the delegation target itself always resolves.
          '';
        };
      };
    };
}
