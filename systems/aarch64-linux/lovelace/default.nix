{ config, lib, pkgs, inputs, modulesPath, ... }:
with inputs; {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" # gives bootloader, sd paritition expansion etc
    agenix.nixosModules.default
    nixos-generators.nixosModules.all-formats
  ];

  age.secrets.secret1.file = "${self.outPath}/secrets/secret1.age";
  system.stateVersion = "22.05";
  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "lovelace";
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  security.sudo.wheelNeedsPassword = false;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 8081 53 ];
    allowedTCPPorts = [ 8081 53 ];
  };

  environment.systemPackages = with pkgs; [ dnsutils tailscale jq ];
  networking.usePredictableInterfaceNames = true;
  boot.kernel.sysctl = { "net.ipv4.conf.all.forwarding" = true; };
  # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1008362877

  services = {
    tailscale = { enable = true; openFirewall = true; };
    adguardhome = {
      enable = true;
      openFirewall = false;
      settings.http.address = "0.0.0.0:8081";
    };
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect =
    let authkeyPath = config.age.secrets.secret1.path;
    in {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2
        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey  file:${authkeyPath}

      '';
    };

  # networking = {
  #   defaultGateway = {
  #     address = "192.168.0.1";
  #     interface = "eth0";
  #   };
  #   interfaces.eth0 = { };

  #   interfaces.br0 = {
  #     ipv4.addresses = [{
  #       address = "10.0.0.1";
  #       prefixLength = 24;
  #     }];
  #   };

  #   interfaces.eth3 = {
  #     useDHCP = true;
  #     ipv4.addresses = [{
  #       address = "192.168.1.2";
  #       prefixLength = 24;
  #     }];
  #   };

  #   bridges.br0 = { interfaces = [ "eth1" "eth2" ]; };

  #   nat.enable = true;
  #   nat.externalInterface = "eth0";
  #   nat.internalInterfaces = [ "br0" ];
  # };

  # services.dhcpd4 = {
  #   enable = true;
  #   extraConfig = ''
  #     option subnet-mask 255.255.255.0;
  #     option routers 10.0.0.1;
  #     option domain-name-servers 10.0.0.1, 9.9.9.9;
  #     subnet 10.0.0.1 netmask 255.255.255.0 {
  #         range 10.0.0.2 10.0.0.100;
  #     }
  #   '';
  #   interfaces = [ "br0" ];
  # };

}
