{ lib, pkgs, config, ... }:
{
  services.autorandr = {
    enable = true;
    defaultTarget = "default";
  };
  # I am using config files rather than the module's options becuase
  # they do not support all the attrbites required for autorandr to
  # detect the profile as 'current' I think it's some `x-*` prop
  environment.etc."xdg/autorandr".source = ./profiles;
}
