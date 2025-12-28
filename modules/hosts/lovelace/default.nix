{ den, nd, inputs, ... }: {
  # Host declaration with user
  den.hosts.aarch64-linux.lovelace.users.aiden = {};

  # Host aspect
  den.aspects.lovelace = {
    includes = [
      nd.common
      nd.locale
      nd.avahi
      nd.tailscale
    ];

    nixos = { config, pkgs, lib, modulesPath, ... }: {
        imports = [
          "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" # gives bootloader, sd paritition expansion etc
          inputs.agenix.nixosModules.default
          inputs.nixos-generators.nixosModules.all-formats
        ];

        age.secrets.secret1.file = "${inputs.self.outPath}/secrets/secret1.age";
        system.stateVersion = "22.05";
        nixpkgs.hostPlatform = "aarch64-linux";
        networking.hostName = "lovelace";
        services.openssh.enable = true;
        services.openssh.openFirewall = true;
        security.sudo.wheelNeedsPassword = false;
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

        environment.systemPackages = with pkgs; [
          dnsutils
          tailscale
          jq
        ];
        networking.usePredictableInterfaceNames = true;
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
        };
        # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1008362877

        narrowdivergent.aspects.tailscale.authKeyPath = config.age.secrets.secret1.path;

        services = {
          adguardhome = {
            enable = true;
            openFirewall = false;
            settings.http.address = "0.0.0.0:8081";
          };
        };

        #services.gvfs.enable = true;
        #services.udisks2.enable = true;
    };
  };
}
