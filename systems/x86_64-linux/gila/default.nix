{ inputs, ... }:
{
  flake.nixosConfigurations.gila = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../../../modules/nixos/avahi/default.nix
      ../../../modules/nixos/common/default.nix
      ../../../modules/nixos/locale/default.nix
      ../../../modules/nixos/powermanagement/default.nix
      ../../../modules/nixos/traefik/default.nix
      ../../../modules/nixos/tailscale/default.nix
      ../../../modules/nixos/adguard/default.nix
      ../../../modules/nixos/home-assistant/default.nix
      ../../../modules/nixos/router/default.nix
      ({ config, pkgs, lib, inputs, ... }: {
        imports = [
          #./pxe.nix
          ./hardware-configuration.nix
          ./disko-config.nix
          #./monitoring.nix
          inputs.disko.nixosModules.default
          inputs.agenix.nixosModules.default
          inputs.switch-fix.nixosModules.switch-fix
        ];

        age.secrets.mosquittoPass.file = "${inputs.self.outPath}/secrets/mosquitto-pass.age";
        age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
        age.secrets.gila-tailscale-authkey.file = "${inputs.self.outPath}/secrets/gila-tailscale-authkey";

        networking.hostName = "gila";
        networking.networkmanager.enable = true;

        environment.systemPackages = with pkgs; [
          tcpdump
          dnsutils
        ];
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
        security.sudo.wheelNeedsPassword = false;
        services.openssh.enable = true;
        services.openssh.openFirewall = false;
        system.stateVersion = lib.mkForce "23.05";
        powerManagement.cpuFreqGovernor = "ondemand";
        services.irqbalance.enable = true;
        services.acpid.enable = true;

        # Module options (modules are imported above, no enable needed)
        narrowdivergent.modules = {
          tailscale = {
            advertiseRoutes = true;
            authKeyPath = config.age.secrets.gila-tailscale-authkey.path;
          };
          common = {
            email = "aiden@oldstreetjournal.co.uk";
            domainName = "sw1a1aa.uk";
          };
          home-assistant = {
            devices = [
              "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
            ];
          };
          router = {
            dns.enable = false; # TODO: remove
            dnsmasq.enable = true;
            internalInterface = "enp2s0";
            externalInterface = "enp1s0";
          };
        };

        systemd.network.wait-online.enable = false;

        services.iperf3.enable = true;
      })
    ];
  };
}
