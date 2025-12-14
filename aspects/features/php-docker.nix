{ lib, ... }:
{
  flake.nixosModules.php-docker = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.php-docker;
    in {
      options.aiden.modules.php-docker.enable = mkEnableOption "php-docker";

      config = mkIf cfg.enable {
        networking.firewall = {
          logRefusedConnections = true;
          enable = true;
          # xdebug. I want to narrow this down to just the docker interface but the veth changes every time
          allowedTCPPorts = [ 9000 ];
          allowedUDPPorts = [ 9000 ];
        };

        virtualisation.docker.enable = true;
      };
    };
}
