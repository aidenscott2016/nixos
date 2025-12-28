{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (config.narrowdivergent.aspects.router)
    internalInterface
    externalInterface
    ;
};
{
  config = {
    networking = {
      firewall.enable = false;
      nftables = {
        enable = true;
        ruleset = (import ./_nft.nix { inherit internalInterface externalInterface; });
      };
    };
  };
}
