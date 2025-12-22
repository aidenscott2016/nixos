{ lib, ... }:
{
  flake.nixosModules.users = { config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.modules.users;
    in
    {
      options.aiden.modules.users = {
        enable = mkEnableOption "user configuration";
      };

      config = mkIf cfg.enable {
        users.users.aiden = {
          uid = 1000;
          # TODO: Move to age.secrets/declarative handling in future
          # initialPassword = "password"; 
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "disk"
            "networkmanager"
            "video"
          ];
        };
        
        users.groups.video.gid = 26;
      };
    };

  flake.homeManagerModules.users = { config, lib, ... }:
    with lib;
    let
      cfg = config.aiden.modules.users;
    in
    {
      options.aiden.modules.users = {
        enable = mkEnableOption "user configuration (home)";
      };
      
      config = mkIf cfg.enable {
        # Future user-specific home-manager config
      };
    };
}
