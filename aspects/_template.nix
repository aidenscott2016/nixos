{ lib, inputs, ... }: {
  flake.nixosModules.example = { config, lib, ... }:
    let
      cfg = config.aiden.modules.example;
    in
    {
      options.aiden.modules.example = {
        enable = lib.mkEnableOption "Example service";
      };

      config = lib.mkIf cfg.enable {
        # NixOS configuration
      };
    };

  flake.homeManagerModules.example = { config, lib, ... }:
    let
      cfg = config.aiden.modules.example;
    in
    {
      options.aiden.modules.example = {
        enable = lib.mkEnableOption "Example home-manager configuration";
      };

      config = lib.mkIf cfg.enable {
        # Home-manager configuration
      };
    };
}
