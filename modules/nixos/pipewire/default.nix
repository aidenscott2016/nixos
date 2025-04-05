{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.aiden.modules.pipewire;
in {
  options.aiden.modules.pipewire = {
    enable = mkEnableOption "pipewire";
  };

  config = mkIf cfg.enable {
    # Enable realtime scheduling for pipewire
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable dconf for EasyEffects
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      easyeffects
    ];
  };
} 