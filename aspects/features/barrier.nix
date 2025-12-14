{ lib, ... }:
{
  flake.nixosModules.barrier = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.barrier;
    in {
      options.aiden.modules.barrier.enable = mkEnableOption "barrier";

      config = mkIf cfg.enable {
        networking.firewall = {
          allowedTCPPorts = [
            24800 # barrier
          ];
        };

        environment.systemPackages = with pkgs; [ barrier ];
      };
    };
}
