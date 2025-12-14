{ lib, ... }:
{
  flake.nixosModules.pipewire = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.pipewire;
    in {
      options.aiden.modules.pipewire.enable = mkEnableOption "pipewire";

      config = mkIf cfg.enable {
        security.rtkit.enable = true;

        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };

        programs.dconf.enable = true;
        environment.systemPackages = with pkgs; [
          easyeffects
        ];
      };
    };
}
