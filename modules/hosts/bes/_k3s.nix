{ ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=servicelb"
      "--write-kubeconfig-mode=644"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 6443 80 443 ];
}
