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
          nvidia.acceptLicense = true;
          permittedInsecurePackages = [
            "qtwebengine-5.15.19"
          ];
        };

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
}
