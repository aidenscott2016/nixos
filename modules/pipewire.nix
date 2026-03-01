{ ... }:
{
  flake.modules.nixos.pipewire =
    { lib, pkgs, config, ... }:
    {
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
}
