{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  enable = config.aiden.modules.router.dns.enable;
in
{
  config = mkIf enable {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = "0.0.0.0";
          access-control = [
            "127.0.0.0/8 allow"
            "10.0.0.1/16 allow"
            "0.0.0.0/0 refuse"
          ];
        };
      };
    };
  };
}
