{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.extraOptions = ''
    min-free = ${toString (1024 * 1024 * 1024)} 
    max-free = ${toString (5 * 1024 * 1024 * 1024)}
  '';
}
