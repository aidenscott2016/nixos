{ lib, ... }:
with lib.aiden;
with lib; {
  enabled = { enabled = true; };
  enableableModule = name:
    params@{ config, ... }:
    configToEnable:
    let cfg = config.aiden.modules.${name};
    in {
      options.aiden.modules.${name}.enabled = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the ${name} module";
      };

      config = mkIf cfg.enabled configToEnable;
    };

  types = {
    mkReverseProxyAppsOption = mkOption {
      type = with types; listOf (submodule {
        options = {
          name = mkOption {
            type = str;
          };
          port = mkOption {
            type = int;
          };
        };
      });
      default = [ ];
    };
  };

  toLocalReverseProxy = foldl'
    (acc: _@{ name, port }:
      recursiveUpdate acc {
        routers."${name}" = {
          service = name;
          rule = "Host(`${name}.sw1a1aa.uk`)";
          tls = true;
        };
        services."${name}" = {
          loadbalancer = {
            servers = [{ url = "http://127.0.0.1:${toString port}"; }];
          };
        };
      }
    )
    { };
}
