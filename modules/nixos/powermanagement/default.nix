params@{ pkgs, lib, config, ... }:
with lib.aiden;
{
  options.aiden.modules.powermanagement = with lib; {
    enabled = mkEnableOption "powermanagement";
  };
  config = {
    services.tlp.enable = true;
  };
}
