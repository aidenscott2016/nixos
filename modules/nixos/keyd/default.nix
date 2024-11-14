# https://wiki.nixos.org/wiki/Keyd
_@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "keyd";
in {
  options = {
    aiden.modules.${moduleName}.enabled = mkEnableOption moduleName;
  };

  config = mkIf config.aiden.modules.${moduleName}.enabled {
    services.keyd = {

      enable = true;
      keyboards = {
        # The name is just the name of the configuration file, it does not really matter
        default = {
          ids = [
            "*"
          ]; # what goes into the [id] section, here we select all keyboards
          # Everything but the ID section:
          settings = {
            # The main layer, if you choose to declare it in Nix
            main = {
              # Maps capslock to escape when pressed and control when held.
              capslock = "overloadt(control, esc, 150)";

            };
            otherlayer = { };
          };
          extraConfig = ''
          '';
        };
      };
    };

  };

}
