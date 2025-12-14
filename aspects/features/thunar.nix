{ lib, ... }:
{
  flake.modules.nixos.thunar = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.thunar;
    in {
      options.aiden.modules.thunar.enable = mkEnableOption "thunar";

      config = mkIf cfg.enable {
        programs.thunar.enable = true;
        programs.thunar.plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];

        environment.systemPackages = with pkgs; [ file-roller ];
      };
    };
}
