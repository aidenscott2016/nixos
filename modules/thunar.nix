{ ... }:
{
  flake.modules.nixos.thunar =
    { pkgs, lib, config, ... }:
    {
        programs.thunar.enable = true;
        programs.thunar.plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];

        # enables unzipping
        environment.systemPackages = with pkgs; [ file-roller ];
    };
}
