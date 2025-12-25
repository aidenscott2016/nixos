{ inputs, ... }:
{
  aiden.paperless.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.paperless or { };
      commonCfg = config.aiden.aspects.common or { };
      domainName = commonCfg.domainName or "sw1a1aa.uk";
    in
    {
      imports = [
        "${inputs.nixpkgs-unstable-pinned}/nixos/modules/services/misc/paperless.nix"
      ];

      disabledModules = [
        "services/misc/paperless.nix"
      ];

      options.aiden.aspects.paperless = {
        enable = mkEnableOption "Paperless document management";
      };

      config = mkIf (cfg.enable or false) {
        services.paperless = {
          enable = true;
          settings = {
            PAPERLESS_CONSUMER_ENABLE_BARCODES = true;
            PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
            PAPERLESS_CONSUMER_BARCODE_SCANNER = "ZXING";
            PAPERLESS_URL = "https://paperless.${domainName}";
            PAPERLESS_USE_X_FORWARD_HOST = false;
            PAPERLESS_PROXY_SSL_HEADER = [
              "HTTP_X_FORWARDED_PROTO"
              "https"
            ];
          };
        };

        # Auto-add to reverse proxy if enabled
        aiden.aspects.reverse-proxy.apps = mkIf (config.aiden.aspects.reverse-proxy.enable or false) [
          {
            name = "paperless";
            port = 28981;
          }
        ];
      };
    };
}
