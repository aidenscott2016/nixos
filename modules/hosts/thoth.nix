{ aiden, inputs, ... }:
{
  # Register thoth host
  den.hosts.x86_64-linux.thoth.users.aiden = { };

  # Define thoth host aspect
  den.aspects.thoth = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.tailscale
      aiden.avahi
    ];

    nixos =
      { pkgs, lib, config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          ../../systems/x86_64-linux/thoth/disk-config.nix
          ../../systems/x86_64-linux/thoth/hardware-configuration.nix
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "thoth.local";
          email = "aiden@thoth.local";
        };

        # Tailscale configuration
        aiden.aspects.tailscale = {
          authKeyPath = config.age.secrets.thoth-tailscale-authkey.path;
          advertiseRoutes = false;
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Agenix secrets
        age.secrets.thoth-tailscale-authkey.file = "${inputs.self.outPath}/secrets/thoth-tailscale-authkey";

        # SSH
        services.openssh.openFirewall = true;

        # Security
        security.sudo.wheelNeedsPassword = false;

        # Networking and firewall
        networking.hostName = "thoth";
        networking.firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [
            53
            8081  # AdGuard Home port
          ];
        };

        # AdGuard Home
        services.adguardhome = {
          enable = true;
          openFirewall = false;
          host = "0.0.0.0";
          port = 8081;
        };

        # Packages
        environment.systemPackages = with pkgs; [
          dnsutils
          tailscale
        ];

        system.stateVersion = "23.05";
      };
  };
}
