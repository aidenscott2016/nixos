{ ... }:
{
  flake.modules.nixos.openttd =
    { lib, pkgs, config, ... }:
    with lib;
    {
      options = {
        aiden.programs.openttd.enable = mkEnableOption "install openttd";
      };

      config = mkIf config.aiden.programs.openttd.enable {
        environment.systemPackages = with pkgs; [ openttd ];
      };
    };
}
