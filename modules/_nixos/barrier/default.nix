params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.narrowdivergent;
enableableModule "barrier" params {
  networking.firewall = {
    allowedTCPPorts = [
      24800 # barrier
    ];
  };

  environment.systemPackages = with pkgs; [ barrier ];
}
