{ ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=traefik"
      "--disable=servicelb"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 6443 ];
}
