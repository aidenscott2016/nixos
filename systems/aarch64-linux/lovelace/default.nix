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


  aiden = {
    modules = {
      avahi.enabled = true;
      common.enabled = true;
    };
  };


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
  services.gvfs.enable = true;
  services.udisks2.enable = true;


}
