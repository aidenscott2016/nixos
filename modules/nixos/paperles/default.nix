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
        PAPERLESS_USE_X_FORWARD_HOST = false;

        # Paperless will return http urls for `next` fiels in paginated API repsonsed without this
        PAPERLESS_PROXY_SSL_HEADER = [
          "HTTP_X_FORWARDED_PROTO"
          "https"
        ];
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
