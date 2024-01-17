params@{ pkgs, lib, config, ... }:
with lib;
let
  deviceParams =
    map (path: "--device=${path}") config.aiden.modules.home-assistant.devices;
  enabled = config.aiden.modules.home-assistant.enabled;
in
{
  options.aiden.modules.home-assistant = {
    enabled = mkEnableOption "home-assistant";
    devices = mkOption {
      type = with types; listOf str;
      example = [ "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0" ];
      description = "A list of devices to mount in the HA image";
      default = [ ];
    };
  };
  config = mkIf enabled {
    networking.hosts."10.0.1.1" = [ "hass.i.narrowdivergent.co.uk" ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        #volumes = [ "/home/aiden/home-ass/:/config" ];
        #volumes = [ "${./config}:/config" ];
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/London";
        labels =
          {
            "traefik.enable" = "true";
            "traefik.http.routers.hass.rule" = "Host(`hass.i.narrowdivergent.co.uk`)";
            "traefik.http.services.hass.loadbalancer.server.port" = "8123";
          };
        image =
          "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
        ] ++ deviceParams;
      };
    };



    security.acme = {
      credentialsFile =
        acceptTerms = true;
      defaults.email = " ligma@nuts.com";
      certs = {
        "i.narrowdivergent.co.uk" = {
          webroot = "/var/lib/acme/acme-challenge/";
          email = "ligma@nuts.com";
        };
      };
    };


    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.homeassistant = {
            acl = [
              "readwrite #"
            ];
            hashedPassword = "$7$101$fid+6PD+4UVQtJho$9g7YOiJuSqO3tYwm1OoCqkUYrcnm1YCQT6y9K+ET5F6iZoBYCMNeXOo6w0d1ru8GctULQthscARhljkxLKlBJA==";
          };
        }
      ];
    };

    services.nginx = {
      enable = false;
      virtualHosts = {
        "hass.i.narrowdivergent.co.uk" = {
          #addSSL = true;
          # enableACME = true;
          locations."/" = {
            proxyPass = "http://10.0.1.1:8123/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_redirect ~^/(.*) $scheme://$http_host/$1;
            '';
          };
        };
      };
    };
  };
}











