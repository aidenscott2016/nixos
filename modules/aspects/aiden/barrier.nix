{
  aiden.barrier.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.barrier or { };
    in
    {
      options.aiden.aspects.barrier = {
        enable = mkEnableOption "Barrier KVM software";
      };

      config = mkIf (cfg.enable or false) {
        networking.firewall.allowedTCPPorts = [ 24800 ];
        environment.systemPackages = with pkgs; [ barrier ];
      };
    };
}
