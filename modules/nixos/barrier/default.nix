params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "barrier" params {
  networking.firewall = {
    allowedTCPPorts = [
      24800 # barrier
    ];
  };

  environment.systemPackages = with pkgs; [ barrier ];
}
