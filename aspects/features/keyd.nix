{ lib, ... }:
{
  flake.nixosModules.keyd = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.keyd;
    in {
      options.aiden.modules.keyd.enable = mkEnableOption "keyd";

      config = mkIf cfg.enable {
        services.keyd = {
          enable = true;
          keyboards = {
            default = {
              ids = [ "*" ];
              settings = {
                main = {
                  capslock = "overloadt(control, esc, 150)";
                };
                otherlayer = { };
              };
              extraConfig = "";
            };
          };
        };
      };
    };
}
