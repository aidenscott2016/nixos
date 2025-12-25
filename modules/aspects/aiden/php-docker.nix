{
  aiden.php-docker.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.php-docker or { };
    in
    {
      options.aiden.aspects.php-docker = {
        enable = mkEnableOption "PHP Docker development environment";
      };

      config = mkIf (cfg.enable or false) {
        networking.firewall = {
          logRefusedConnections = true;
          enable = true;
          # xdebug - want to narrow down to docker interface but veth changes
          allowedTCPPorts = [ 9000 ];
          allowedUDPPorts = [ 9000 ];
        };

        virtualisation.docker.enable = true;
      };
    };
}
