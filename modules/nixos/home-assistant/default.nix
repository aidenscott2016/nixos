params@{ pkgs, lib, config, ... }:
with lib;
let
  deviceParams =
    map (path: "--device=${path}") config.aiden.modules.home-assistant.devices;
in {
  options.aiden.modules.home-assistant = {
    enabled = mkEnableOption "home-assistant";
    devices = mkOption {
      type = with types; listOf str;
      example = ["/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"];
      description = "A list of devices to mount in the HA image";
      default = [ ];
    };
  };
  config.virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/London";
      image =
        "ghcr.io/home-assistant/home-assistant:stable"; 
      extraOptions = [ "--network=host" ] ++ deviceParams;
    };
  };
}
