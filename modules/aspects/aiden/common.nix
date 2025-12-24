{ aiden, inputs, ... }:
{
  aiden.common = {
    # Include gc aspect for garbage collection
    includes = [ aiden.gc ];

    nixos =
      { config, pkgs, lib, ... }:
      with lib;
      let
        cfg = config.aiden.aspects.common;
      in
      {
        options.aiden.aspects.common = {
          domainName = mkOption {
            type = types.str;
            description = "Domain name for this host";
          };
          email = mkOption {
            type = types.str;
            description = "Email address for this host";
          };
          publicKey = mkOption {
            type = types.str;
            default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
            description = "SSH public key for aiden user";
          };
        };

        config = {
          nixpkgs.config.allowUnfree = true;

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
        };
      };
  };
}
