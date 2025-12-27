{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (config.aiden.modules.router)
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
        ruleset = (import ./nft.nix { inherit internalInterface externalInterface; });
      };
    };
  };
}
