{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.autorandr;
in
{
  services.autorandr = {
    enable = true;
    defaultTarget = "default";
  };
  # I am using config files rather than the module's options becuase
  # they do not support all the attrbites required for autorandr to
  # detect the profile as 'current' I think it's some `x-*` prop

  # systemd.user.services.autorandr-logon = {
  #   wantedBy = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   enable = true;
  #   description = "Autorandr logon execution hook";
  #   serviceConfig.PassEnvironment = "DISPLAY";

  #   serviceConfig = {
  #     ExecStart = ''
  #       ${pkgs.autorandr}/bin/autorandr docked
  #     '';
  #     Type = "oneshot";
  #     # RemainAfterExit = false;
  #     # KillMode = "process";
  #   };
  # };
  environment.etc."xdg/autorandr".source = ./profiles;
}




# ${# optionalString cfg.ignoreLid "--ignore-lid"}
