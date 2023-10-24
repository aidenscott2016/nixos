{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.aiden;
  packages = [
    #"ios"
    "redshift"
    "android"
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
  all-packages = map (key: ./${key}) packages;

in {
  options.aiden.modules.android = { };
  imports = all-packages;

}

# move all moduels to a directory and rename to default.nix
# wrap all the modules in an enabler for my
