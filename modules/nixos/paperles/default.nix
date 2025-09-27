params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "paperless";
  cfg = config.aiden.modules.${moduleName};
in
{
  options = {
    aiden.modules.${moduleName}.enable = mkEnableOption moduleName;
  };
  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      settings = {
        PAPERLESS_URL = "https://paperless.sw1a1aa.uk";
      };
    };
    aiden.modules.reverseProxy.apps = [
      {
        name = "paperless";
        port = 28981;
      }
    ];

  };
}
