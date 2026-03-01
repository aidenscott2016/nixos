{ ... }:
{
  flake.modules.nixos.router-firewall =
    { config, lib, ... }:
    with {
      inherit (config.aiden.modules.router)
        enable internalInterface externalInterface;
    };
    {
      config = lib.mkIf enable {
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
