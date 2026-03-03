{ ... }:
{
  flake.modules.nixos.keyd =
    { lib, pkgs, config, ... }:
    with lib;
    {
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
}
