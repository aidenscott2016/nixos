{ pkgs, config, lib, mylib, ... }:
with lib;
let cfg = config.aiden.modules.android;
in {
  options.aiden.modules.android.enabled = mkOption {
    type = types.bool;
    default = false;
  };
  config = {
    environment.systemPackages = with pkgs; [ android-studio cmake python3 ];
    programs.adb.enable = true;
    users.groups.plugdev = { };
    users.users.aiden.extraGroups = [ "adbusers" "plugdev" ];
  };
}
