{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ android-studio cmake python3 ];
  programs.adb.enable = true;
  users.groups.plugdev = { };
  users.users.aiden.extraGroups = [ "adbusers" "plugdev" ];
}

