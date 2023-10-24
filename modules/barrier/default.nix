{ pkgs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      24800 # barrier
    ];
  };

  environment.systemPackages = with pkgs; [ barrier ];
}
