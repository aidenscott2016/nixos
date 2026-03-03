{ ... }:
{
  flake.modules.nixos.router-firewall =
    { config, ... }:
    with {
      inherit (config.aiden.modules.router)
        internalInterface externalInterface;
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
    };
}
