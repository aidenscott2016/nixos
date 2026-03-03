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
      };
    };
}
