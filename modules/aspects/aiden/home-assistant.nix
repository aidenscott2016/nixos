{
  aiden.home-assistant.nixos =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.home-assistant or { };
      commonCfg = config.aiden.aspects.common or { };
      domainName = commonCfg.domainName or "sw1a1aa.uk";
      fqdn = "hass.${domainName}";
      container-name = "home-assistant";
      service-name = "${config.virtualisation.oci-containers.backend}-${container-name}";
      deviceParams = map (path: "--device=${path}") (cfg.devices or [ ]);
    in
    {
      options.aiden.aspects.home-assistant = {
        devices = mkOption {
          type = types.listOf types.str;
          example = [
            "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
          ];
          description = "A list of devices to mount in the HA image";
          default = [ ];
        };
        mosquittoPasswordFile = mkOption {
          type = types.str;
          description = "Path to mosquitto password file";
        };
      };

      config = {
        systemd.services.${service-name}.after = [ "traefik.service" ];
        networking.hosts."10.0.1.1" = [ fqdn ];

        virtualisation.podman.dockerSocket.enable = true;
        virtualisation.podman.dockerCompat = true;
        virtualisation.oci-containers = {
          backend = "podman";
          containers.${container-name} = {
            volumes = [ "home-assistant:/config" ];
            environment.TZ = "Europe/London";
            labels = {
              "traefik.enable" = "true";
              "traefik.http.routers.hass.rule" = "Host(`${fqdn}`)";
              "traefik.http.routers.hass.tls" = "true";
              "traefik.http.services.hass.loadbalancer.server.url" = "http://10.0.0.1:8123";
              "traefik.http.routers.hass.entrypoints" = "websecure";
            };
            image = "ghcr.io/home-assistant/home-assistant:stable";
            extraOptions = [ "--network=host" ] ++ deviceParams;
          };
        };

        services.mosquitto = {
          enable = true;
          listeners = [
            {
              users.homeassistant = {
                acl = [ "readwrite #" ];
                hashedPasswordFile = cfg.mosquittoPasswordFile;
              };
            }
          ];
        };
      };
    };
}
