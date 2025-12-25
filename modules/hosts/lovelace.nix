{ aiden, inputs, ... }:
{
  # Register lovelace host
  den.hosts.aarch64-linux.lovelace.users.aiden = { };

  # Define lovelace host aspect
  den.aspects.lovelace = {
    includes = [
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
          "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
          inputs.agenix.nixosModules.default
          inputs.nixos-generators.nixosModules.all-formats
        ];

        # System settings
        nixpkgs.hostPlatform = "aarch64-linux";
        networking.hostName = "lovelace";

        # Set common options
        aiden.aspects.common = {
          domainName = "lovelace.sw1a1aa.uk";
          email = "aiden@lovelace.sw1a1aa.uk";
        };

        # Set tailscale options
        age.secrets.secret1.file = "${inputs.self.outPath}/secrets/secret1.age";
        aiden.aspects.tailscale = {
          authKeyPath = config.age.secrets.secret1.path;
          advertiseRoutes = false;
        };

        # SSH
        services.openssh.openFirewall = true;

        # Security
        security.sudo.wheelNeedsPassword = false;

        # Networking
        networking.usePredictableInterfaceNames = true;
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
        };

        networking.firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [
            8081
            53
          ];
          allowedTCPPorts = [
            8081
            53
          ];
        };

        # AdGuard Home DNS
        services.adguardhome = {
          enable = true;
          openFirewall = false;
          settings.http.address = "0.0.0.0:8081";
        };

        # Packages
        environment.systemPackages = with pkgs; [
          dnsutils
          jq
        ];

        system.stateVersion = "22.05";
      };
  };
}
