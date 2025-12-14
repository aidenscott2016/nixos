{ lib, ... }:
{
  flake.modules.nixos.android = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.android;
    in {
      options.aiden.modules.android.enable = mkEnableOption "android";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          android-studio
          cmake
          python3
        ];
        programs.adb.enable = true;
        users.groups.plugdev = { };
        users.users.aiden.extraGroups = [
          "adbusers"
          "plugdev"
        ];
      };
    };
}
