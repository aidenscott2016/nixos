# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, disko, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gila"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  security.sudo.wheelNeedsPassword = false;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.mkForce "23.05"; # Did you read the comment?
  #services.openssh.settings.PermitRootLogin = "yes";
  #
  #
  #
  #
  #isoImage.squashfsCompression = "zstd -Xcompression-level 5";

  powerManagement.cpuFreqGovernor = "ondemand";

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [ "copytoram" ];
  boot.supportedFilesystems =
    pkgs.lib.mkForce [ "btrfs" "vfat" "xfs" "ntfs" "cifs" ];

  services.irqbalance.enable = true;

  networking.dhcpcd.enable = true;
  networking.usePredictableInterfaceNames = true;
  networking.firewall.enable = false;
  networking.firewall.interfaces.eth0.allowedTCPPorts = [ 4949 ];
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.br0.allowedUDPPorts = [ 53 ];

  services.acpid.enable = true;

  services.unbound = {
    enable = false;
    settings = {
      server = {
        interface = [ "127.0.0.1" "10.42.42.42" ];
        access-control =
          [ "0.0.0.0/0 refuse" "127.0.0.0/8 allow" "10.42.42.0/24 allow" ];
      };
    };
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

  };

  networking = {
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    interfaces.eth0 = { };

    interfaces.br0 = {
      ipv4.addresses = [{
        address = "10.0.0.1";
        prefixLength = 24;
      }];
    };

    interfaces.eth3 = {
      useDHCP = true;
      ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };

    bridges.br0 = { interfaces = [ "eth1" "eth2" ]; };

    nat.enable = true;
    nat.externalInterface = "eth0";
    nat.internalInterfaces = [ "br0" ];
  };

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      option routers 10.0.0.1;
      option domain-name-servers 10.0.0.1, 9.9.9.9;
      subnet 10.0.0.1 netmask 255.255.255.0 {
          range 10.0.0.2 10.0.0.100;
      }
    '';
    interfaces = [ "br0" ];
  };

  services.openssh.settings.PermitRootLogin = "yes";
}
