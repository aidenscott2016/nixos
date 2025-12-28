{ nd, ... }: {
  nd.pipewire = {
    nixos =
{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = {
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
;
  };
}
