{ lib, ... }:
{
  flake.nixosModules.router-firewall = { config, lib, ... }:
    with lib;
    let
      inherit (config.aiden.modules.router)
        enable
        internalInterface
        externalInterface
        ;
    in {
      config = mkIf enable {
        networking = {
          firewall.enable = false;
          nftables = {
            enable = true;
            ruleset = (import ../../modules/nixos/router/firewall/nft.nix { inherit internalInterface externalInterface; });
          };
        };
      };
    };
}
