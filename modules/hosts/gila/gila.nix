{ inputs, config, ... }:
{
  flake.nixosConfigurations.gila = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./_hardware-configuration.nix
      ./_disko-config.nix
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      inputs.switch-fix.nixosModules.switch-fix
    ] ++ (with config.flake.modules.nixos; [
      common locale adguard avahi traefik tailscale router
    ]) ++ [
      config.flake.modules.nixos."home-assistant"
    ] ++ [
      ({ config, pkgs, lib, ... }: {
        networking.hostName = "gila";
        system.stateVersion = "23.05";
        nixpkgs.overlays = [ inputs.self.overlays.default ];

        age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
        age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
        age.secrets.gila-tailscale-authkey.file = "${inputs.self.outPath}/secrets/gila-tailscale-authkey";

        networking.networkmanager.enable = true;

        environment.systemPackages = with pkgs; [
          tcpdump
          dnsutils
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;
        boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
        boot.kernelParams = [ "copytoram" ];
        boot.supportedFilesystems = pkgs.lib.mkForce [
          "btrfs"
          "vfat"
          "xfs"
          "ntfs"
          "cifs"
        ];

        security.sudo.wheelNeedsPassword = false;
        services.openssh.enable = true;
        services.openssh.openFirewall = false;
        powerManagement.cpuFreqGovernor = "ondemand";
        services.irqbalance.enable = true;
        services.acpid.enable = true;
        services.iperf3.enable = true;

        systemd.network.wait-online.enable = false;

        aiden.modules = {
          common = {
            email = "aiden@oldstreetjournal.co.uk";
            domainName = "sw1a1aa.uk";
          };
          tailscale = {
            advertiseRoutes = true;
            authKeyPath = config.age.secrets.gila-tailscale-authkey.path;
          };
          home-assistant.devices = [
            "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
          ];
          router = {
            dns.enable = false;
            dnsmasq.enable = true;
            internalInterface = "enp2s0";
            externalInterface = "enp1s0";
          };
        };
      })
    ];
  };
}
