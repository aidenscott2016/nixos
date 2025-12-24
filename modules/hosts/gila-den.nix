{ aiden, inputs, ... }:
{
  # Register gila-den host
  den.hosts.x86_64-linux.gila-den.users.aiden = { };

  # Define gila-den host aspect
  den.aspects.gila-den = {
    includes = [
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.powermanagement
      aiden.traefik
      aiden.tailscale
      aiden.avahi
      aiden.adguard
      aiden.home-assistant
      aiden.router
    ];

    nixos =
      { pkgs, lib, config, ... }:
      {
        imports = [
          ../../systems/x86_64-linux/gila/hardware-configuration.nix
          ../../systems/x86_64-linux/gila/disko-config.nix
          inputs.disko.nixosModules.default
          inputs.agenix.nixosModules.default
          inputs.switch-fix.nixosModules.switch-fix
        ];

        # Secrets
        age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
        age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
        age.secrets.gila-tailscale-authkey.file = "${inputs.self.outPath}/secrets/gila-tailscale-authkey";

        # Set common options
        aiden.aspects.common = {
          email = "aiden@oldstreetjournal.co.uk";
          domainName = "sw1a1aa.uk";
        };

        # Set tailscale options
        aiden.aspects.tailscale = {
          advertiseRoutes = true;
          authKeyPath = config.age.secrets.gila-tailscale-authkey.path;
        };

        # Set traefik options
        aiden.aspects.traefik = {
          cloudflareCredentialsFile = config.age.secrets.cloudflareToken.path;
        };

        # Set home-assistant options
        aiden.aspects.home-assistant = {
          devices = [
            "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
          ];
          mosquittoPasswordFile = config.age.secrets.mosquittoPass.path;
        };

        # Set router options
        aiden.aspects.router = {
          internalInterface = "enp2s0";
          externalInterface = "enp1s0";
          dns.enable = false;
          dnsmasq.enable = true;
        };

        # Networking
        networking.hostName = "gila";
        networking.networkmanager.enable = true;
        systemd.network.wait-online.enable = false;

        # Packages
        environment.systemPackages = with pkgs; [
          tcpdump
          dnsutils
        ];

        # Boot
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
        };
        boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
        boot.kernelParams = [ "copytoram" ];
        boot.supportedFilesystems = pkgs.lib.mkForce [
          "btrfs"
          "vfat"
          "xfs"
          "ntfs"
          "cifs"
        ];

        # Security
        security.sudo.wheelNeedsPassword = false;

        # SSH
        services.openssh.openFirewall = false;

        # Services
        powerManagement.cpuFreqGovernor = "ondemand";
        services.irqbalance.enable = true;
        services.acpid.enable = true;
        services.iperf3.enable = true;

        system.stateVersion = lib.mkForce "23.05";
      };
  };
}
