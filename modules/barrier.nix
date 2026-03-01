{ ... }:
{
  flake.modules.nixos.barrier =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        networking.firewall = {
          allowedTCPPorts = [
            24800 # barrier
          ];
        };

        environment.systemPackages =  [ barrier ];
    };
}
