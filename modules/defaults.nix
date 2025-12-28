{ den, ... }: {
  # Common defaults (NO stateVersion - hosts set their own)
  den.default = {
    nixos.nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
