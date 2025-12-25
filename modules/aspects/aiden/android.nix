{
  aiden.android.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.android or { };
    in
    {
      options.aiden.aspects.android = {
        enable = mkEnableOption "Android development tools";
      };

      config = mkIf (cfg.enable or false) {
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
