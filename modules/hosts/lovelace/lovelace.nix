{ inputs, config, ... }:
{
  flake.nixosConfigurations.lovelace = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
      inputs.agenix.nixosModules.default
      inputs.nixos-generators.nixosModules.all-formats
    ] ++ (with config.flake.modules.nixos; [
      common locale avahi tailscale
    ]) ++ [
      ({ config, pkgs, ... }: {
        networking.hostName = "lovelace";
        system.stateVersion = "22.05";
        nixpkgs.hostPlatform = "aarch64-linux";

        age.secrets.secret1.file = "${inputs.secrets}/secret1.age";

        services.openssh.enable = true;
        services.openssh.openFirewall = true;
        security.sudo.wheelNeedsPassword = false;

        networking.firewall = {
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
          allowedUDPPorts = [ 8081 53 ];
          allowedTCPPorts = [ 8081 53 ];
        };

        networking.usePredictableInterfaceNames = true;
        boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

        environment.systemPackages = with pkgs; [
          dnsutils
          tailscale
          jq
        ];

        services.adguardhome = {
          enable = true;
          openFirewall = false;
          settings.http.address = "0.0.0.0:8081";
        };

        aiden.modules.tailscale.authKeyPath = config.age.secrets.secret1.path;
      })
    ];
  };
}
