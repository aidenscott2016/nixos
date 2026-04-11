{ ... }:
{
  flake.modules.nixos.tailscale-udp-gro =
    { lib, pkgs, config, ... }:
    let
      cfg = config.aiden.modules.tailscale-udp-gro;
    in
    {
      options.aiden.modules.tailscale-udp-gro.interfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Interfaces on which to enable UDP GRO forwarding for Tailscale subnet routing.";
      };

      config.systemd.services.tailscale-udp-gro = {
        after = [ "network-pre.target" ];
        wants = [ "network-pre.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "tailscale-udp-gro" (lib.concatMapStrings (iface: ''
            ${pkgs.ethtool}/bin/ethtool -K ${iface} rx-udp-gro-forwarding on rx-gro-list off
          '') cfg.interfaces);
        };
      };
    };
}
