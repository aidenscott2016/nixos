{ inputs, ... }:
{
  flake.modules.nixos.common =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.modules.common;
    in
    {
      imports = [ inputs.self.modules.nixos.gc ];

      options.aiden.modules.common = {
        domainName = mkOption { type = types.str; };
        email = mkOption { type = types.str; };
        publicKey = mkOption {
          type = types.str;
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
        };
      };

      config = {
        system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or "dirty";
        nix.registry.self.flake = inputs.self;

        nixpkgs.config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "qtwebengine-5.15.19"
          ];
        };

        nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        nix.settings = {
          auto-optimise-store = true;
          trusted-users = [ "aiden" ];
          experimental-features = [ "nix-command" "flakes" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0mWqyPMV+FnfCelaCYkFdeVX6Ht7cg="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };

        programs.fish.enable = true;

        users.users.aiden = {
          uid = 1000;
          initialPassword = "password";
          isNormalUser = true;
          shell = pkgs.fish;
          extraGroups = [
            "wheel"
            "disk"
            "networkmanager"
            "video"
          ];
          openssh.authorizedKeys.keys = [
            cfg.publicKey
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFPzeWccRjpB6jb83yXaZ8oaugea4TZ7bXmhMbeop64"
          ];
        };
        users.groups.video.gid = 26;

        environment.sessionVariables = {
          EDITOR = "vim";
          VISUAL = "vim";
        };

        environment.systemPackages = with pkgs; [ vim ];
      };
    };
}
