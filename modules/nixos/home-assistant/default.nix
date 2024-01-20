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
    networking.hosts."10.0.1.1" = [ "hass.sw1a1aa.uk" ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        #volumes = [ "/home/aiden/home-ass/:/config" ];
        #volumes = [ "${./config}:/config" ];
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/London";
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.hass.rule" = "Host(`hass.sw1a1aa.uk`)";
          "traefik.http.routers.hass.tls" = "true";
          "traefik.http.services.hass.loadbalancer.server.url" = "10.0.0.1";
          "traefik.http.services.hass.loadbalancer.server.port" = "8123";
          "traefik.http.routers.hass.entrypoints" = "websecure";
        };
        image =
          "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
        ] ++ deviceParams;
      };
    };



    security.acme = {
      acceptTerms = true;
      defaults.email = " ligma@nuts.com";
      certs = {
        "sw1a1aa.uk" = {
          domain = "sw1a1aa.uk";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.cloudflareToken.path;
          extraDomainNames = [ "*.sw1a1aa.uk" ];
        };
      };
    };


    services.mosquitto = {
      enable = true;
      listeners = [{
        users.homeassistant = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = config.age.secrets.mosquittoPass.path;
        };
      }];
    };
  };
}











