{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (config.aiden.modules.router)
    enable
    internalInterface
    externalInterface
    ;
};
{
  config = lib.mkIf enable {
    networking = {
      firewall.enable = false;
      nftables = {
        enable = true;
        ruleset = (import ./nft.nix { inherit internalInterface externalInterface; });
      };
    };
  };
}
