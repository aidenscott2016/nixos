params@{ pkgs, lib, config, inputs, ... }:
with lib;
let cfg = config.aiden.modules.k3s;
in {
  options.aiden.modules.k3s = { enabled = mkEnableOption "k3s"; };

  config = mkIf false {

    # networking.interfaces.enp1s0.useDHCP = true;
    # networking.interfaces.enp1s0.ipv4.addresses = [{
    #   address = "10.0.1.200";
    #   prefixLength = 24;
    # }];
    #networking.bridges = { "br0" = { interfaces = [ "enp1s0" ]; }; }; #
    # # networking.useNetworkd = true;

    # systemd.network.networks."10-bridge" = {
    #   matchConfig.Name = [ "enp1s0" "vm-*" ];
    #   networkConfig = { Bridge = "br0"; };
    # };

    # systemd.network.netdevs."br0" = {
    #   netdevConfig = {
    #     Name = "br0";
    #     Kind = "bridge";
    #   };
    # };

    # systemd.network.networks."10-lan" = {
    #   matchConfig.Name = "enp1s0";
    #   networkConfig = { useDHCP = "yes"; };
    # };

    # systemd.network.networks."10-lan-bridge" = {
    #   matchConfig.Name = "br0";
    #   # networkConfig = {
    #   #   # Address = [ "10.0.1.1/24" ];
    #   #   # Gateway = "10.0.1.1";
    #   #   # DNS = [ "10.0.1.1" ];
    #   #   IPv6AcceptRA = true;
    #   # };
    #   linkConfig.RequiredForOnline = "routable";
    # };

    # microvm.vms = {
    #   my-microvm = {
    #     # The package set to use for the microvm. This also determines the microvm's architecture.
    #     # Defaults to the host system's package set if not given.
    #     # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
    #     #specialArgs = {};
    #     # The configuration for the MicroVM.
    #     # Multiple definitions will be merged as expected.
    #     config = {
    #       # It is highly recommended to share the host's nix-store
    #       # with the VMs to prevent building huge images.
    #       microvm = {
    #         forwardPorts = [ # from=host|guest, proto=tcp|udp,
    #           {
    #             from = "host";
    #             host.port = 10022;
    #             guest.port = 22;
    #           }
    #           {
    #             from = "host";
    #             host.port = 10080;
    #             guest.port = 80;
    #           }
    #         ];
    #       };
    #     };
    #   };
    # };
  };
}
