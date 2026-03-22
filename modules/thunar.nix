{ ... }:
{
  flake.modules.nixos.thunar =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        programs.thunar.enable = true;
        programs.thunar.plugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
        ];

        # enables unzipping
        environment.systemPackages =  [ file-roller ];
    };
}
