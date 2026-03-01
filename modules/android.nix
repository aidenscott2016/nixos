{ ... }:
{
  flake.modules.nixos.android =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        environment.systemPackages =  [
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
}
