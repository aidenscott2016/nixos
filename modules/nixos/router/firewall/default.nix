{ config, lib, pkgs, ... }:
with {
  inherit (config.aiden.modules.router)
    enabled internalInterface externalInterface;
}; {
  config = lib.mkIf enabled {
    networking = {
      firewall.enable = false;
      nftables = {
        enable = true;
        ruleset = (import ./nft.nix {inherit internalInterface externalInterface;});
      };
    };
  };
}
