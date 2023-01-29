inputs@{ ... }:
{
  networking.firewall = {
    logRefusedConnections = true;
    enable = true;
    # xdebug. I want to narrow this down to just the docker interface but the veth changes every time
    allowedTCPPorts = [ 9000 ];
    allowedUDPPorts = [ 9000 ];
  };

  virtualisation.docker.enable = true;
}
