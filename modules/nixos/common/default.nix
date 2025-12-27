{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.aiden.modules.common;
in
{
  imports = [
    ../gc/default.nix
  ];

  options.aiden.modules.common = {
    domainName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    publicKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
    };
  };

  config = {
    # gc is imported above and always-on
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.settings.trusted-users = [ "aiden" ];
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    users.users.aiden = {
      uid = 1000;
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "disk"
        "networkmanager"
        "video"
      ];
      openssh.authorizedKeys.keys = [ cfg.publicKey ];
    };
    users.groups.video.gid = 26;

    environment.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    environment.systemPackages = with pkgs; [ vim ];

    # programs.bash.shellInit = ''
    #   set -o vi
    # '';
  };
}
