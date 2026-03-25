# Tunnels Tailscale through Mullvad.
#
# Packet flow:
#   App → tailscale0 (Tailscale WireGuard) → mullvad0 (Mullvad WireGuard)
#   → Mullvad server → DERP relay → Tailscale peer
#
# Because our external IP is Mullvad's server, Tailscale cannot establish
# direct peer connections and transparently falls back to DERP relays.
# Peers see the DERP server address, not your real IP or Mullvad's IP.
#
# DNS: systemd-resolved mediates both VPNs. Tailscale registers split-DNS
# for *.ts.net (MagicDNS); Mullvad pushes its resolver as the default.
# Resolved merges them: Tailscale names go to Tailscale DNS, everything
# else goes through Mullvad's DNS server.
{ ... }:
{
  flake.modules.nixos.vpn-chain =
    { lib, config, ... }:
    with lib;
    {
      services.mullvad-vpn.enable = true;

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      # systemd-resolved lets Mullvad and Tailscale MagicDNS coexist without
      # fighting over /etc/resolv.conf.
      services.resolved.enable = true;
      networking.networkmanager.dns = "systemd-resolved";

      # Trust the Tailscale interface so the NixOS firewall doesn't block
      # incoming mesh traffic. Tailscale encrypts and authenticates this
      # traffic itself; further filtering at this level adds no security.
      networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };
}
