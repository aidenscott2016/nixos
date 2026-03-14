{ ... }:
{
  flake.modules.nixos.traefik =
    { pkgs, lib, config, ... }:
    let
      inherit (config.aiden.modules.common) domainName email;
    in
    {
        security.acme = {
          acceptTerms = true;
          defaults.email = email;
          certs = {
            "${domainName}" = {
              dnsProvider = "cloudflare";
              credentialsFile = config.age.secrets.cloudflareToken.path;
              extraDomainNames = [ "*.${domainName}" ];
              dnsResolver = "1.1.1.1:53";
            };
          };
        };

        users.users.traefik.extraGroups = [ "acme" ]; # to read acme folder
        services.traefik = {
          enable = true;
          group = "podman";
          staticConfigOptions = {
            api = {
              dashboard = true;
              insecure = true;
            };
            accessLog = {
              fields = {
                defaultMode = "keep";
                headers.defaultMode = "keep";
              };
            };
            global = {
              checkNewVersion = false;
              sendAnonymousUsage = false;
            };
            providers.docker = {
              exposedByDefault = false;
              endpoint = "unix:///var/run/podman/podman.sock";
            };
            entrypoints = {
              websecure.address = ":443";
            };
          };
          dynamicConfigOptions = {
            tls = {
              stores.default = {
                defaultCertificate = {
                  certFile = "/var/lib/acme/${domainName}/fullchain.pem";
                  keyFile  = "/var/lib/acme/${domainName}/key.pem";
                };
              };
            };
          };
        };
    };
}
