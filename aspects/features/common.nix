{ lib, ... }:
{
  flake.nixosModules.common = { config, lib, pkgs, inputs, ... }:
    with lib;
    let cfg = config.aiden.modules.common;
    in {
      options.aiden.modules.common = {
        enable = mkEnableOption "common system configuration";
        domainName = mkOption {
          type = types.str;
          description = "Domain name for the system";
        };
        email = mkOption {
          type = types.str;
          description = "Email address for system notifications and ACME";
        };
        publicKey = mkOption {
          type = types.str;
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
          description = "SSH public key for aiden user";
        };
      };

      config = mkIf cfg.enable {
        aiden.modules.users.enable = true;
        aiden.modules.cli-base.enable = true;
        aiden.modules.nix.enable = true;
        aiden.modules.gc.enable = true;

        users.users.aiden.openssh.authorizedKeys.keys = [ cfg.publicKey ];
      };
    };
  
  flake.homeManagerModules.common = { config, lib, ... }: {
      # Placeholder for future common home-manager config
  };
}
