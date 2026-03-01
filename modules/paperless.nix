{ ... }:
{
  flake.modules.nixos.paperless =
    { lib, pkgs, config, ... }:
    with lib;
    {
      services.paperless = {
        enable = true;
        settings = {
          PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
          PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
          PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";

          PAPERLESS_URL = "https://paperless.sw1a1aa.uk";
          PAPERLESS_USE_X_FORWARD_HOST = false;

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
