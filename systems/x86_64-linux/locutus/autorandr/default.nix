{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.autorandr;
in {
  services.autorandr = {
    enable = true;
    defaultTarget = "99-default";
    ignoreLid = true;
  };
  # I am using config files rather than the module's options becuase
  # they do not support all the attrbites required for autorandr to
  # detect the profile as 'current' I think it's some `x-*` prop

  systemd.user.services.autorandr-logon = {
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    enable = true;
    description = "Autorandr logon execution hook";

    serviceConfig = {
      Environment = "XDG_CONFIG_DIRS=/etc/xdg";
      ExecStart = ''
        ${pkgs.autorandr}/bin/autorandr \
           --change \
           --default ${cfg.defaultTarget} \
           ${optionalString cfg.ignoreLid "--ignore-lid"}
      '';
      Type = "oneshot";
    };
  };
  environment.etc."xdg/autorandr".source = ./profiles;
}

# ${# optionalString cfg.ignoreLid "--ignore-lid"}
