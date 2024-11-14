params@{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.aiden.modules.powermanagement;
in
{
  options.aiden.modules.powermanagement =  {
    enabled = mkEnableOption "powermanagement";
  };
  config = mkIf cfg.enabled {
    services.tlp.enable = true;
  };
}
