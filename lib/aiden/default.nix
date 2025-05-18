{ lib, ... }:
with lib.aiden;
with lib;
{
  enabled = {
    enable = true;
  };
  enableableModule =
    name:
    params@{ config, ... }:
    configToEnable:
    let
      cfg = config.aiden.modules.${name};
    in
    {
      options.aiden.modules.${name}.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the ${name} module";
      };

      config = mkIf cfg.enable configToEnable;
    };

  types = {
    mkReverseProxyAppsOption = mkOption {
      type =
        with types;
        listOf (submodule {
          options = {
            name = mkOption {
              type = str;
            };
            port = mkOption {
              type = int;
            };
            proto = mkOption {
              type = str;
              default = "http";
            };
          };
        });
      default = [ ];
    };
  };

  toLocalReverseProxy = foldl' (
    acc:
    _@{
      name,
      port,
      proto,
    }:
    recursiveUpdate acc {
      routers."${name}" = {
        service = name;
        rule = "Host(`${name}.sw1a1aa.uk`)";
        tls = true;
      };
      services."${name}" = {
        loadbalancer = {
          servers = [ { url = "${proto}://127.0.0.1:${toString port}"; } ];
        };
      };
    }
  ) { };
}
