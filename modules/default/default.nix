{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.aiden;
  packages = [
    #"ios"
    "redshift"
    # "printer"
    # "ssh"
    # "gc"
    # "barrier"
    # "transmission"
    # "jellyfin"
    # "cli-base"
    # "desktop"
    # "nixos"
    # "multimedia"
    # "emacs"
    # "steam"
    # "virtualbox"
  ];
  enableable = {
    enabled = mkOption {
      type = types.bool;
      default = false;
    };
  };
  all-packages = map (key: ./${key}.nix) packages;

in {
  imports = all-packages;
}

# move all moduels to a directory and rename to default.nix
# wrap all the modules in an enabler for my namespace
