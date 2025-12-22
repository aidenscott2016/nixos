{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
with inputs;
{
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

  aiden = {
    modules = {
      tailscale = {
        enable = true;
        authKeyPath = config.age.secrets.secret1.path;
      };
      avahi.enable = true;
      common.enable = true;
      locale.enable = true;
    };
  };

  services = {
    adguardhome = {
      enable = true;
      openFirewall = false;
      settings.http.address = "0.0.0.0:8081";
    };
  };

  #services.gvfs.enable = true;
  #services.udisks2.enable = true;

}
