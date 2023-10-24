# { config, pkgs, lib, maimpick, ... }:

# {
#   imports = [
#     ./hardware-configuration.nix
#     ./packages.nix
#     ../../modules/ios.nix
#     ./autorandr
#     ../../modules/redshift.nix
#     ../../modules/printer.nix
#   ];
#   environment.systemPackages = with pkgs; [
#     maimpick.packages.x86_64-linux.maimpick
#   ];

#   services.openssh.enable = true;
#   services.openssh.passwordAuthentication = false;

#   networking.firewall = {
#     logRefusedConnections = true;
#     enable = true;
#     # xdebug. I want to narrow this down to just the docker interface but the veth changes every time
#     allowedTCPPorts = [ 9000 ];
#     allowedUDPPorts = [ 9000 ];
#   };

#   boot.loader.systemd-boot.enable = true;
#   boot.loader.efi.canTouchEfiVariables = true;

#   networking.hostName = "lars";
#   networking.networkmanager.enable = true;

#   services =
#     {
#       fstrim.enable = true;
#       #this is enabled by hardware-support. It is unecessary since
#       #there is an SSD
#       hdapsd.enable = false;
#       upower.enable = true;
#       auto-cpufreq.enable = true;

#       xserver.enable = true;

#     };

#   hardware = {
#     enableAllFirmware = true;
#     bluetooth.enable = true;
#     pulseaudio.enable = true;
#   };

#   security.sudo.wheelNeedsPassword = false;

#   virtualisation.docker.enable = true;

#   programs.gnupg.agent = {
#     enable = true;
#     pinentryFlavor = "gtk2";
#     enableSSHSupport = true;
#   };

#   programs.nm-applet.enable = true;

#   programs.steam = {
#     enable = true;
#     remotePlay.openFirewall = true;
#     dedicatedServer.openFirewall = true;
#   };

#   boot.initrd.luks.devices = {
#     root = {
#       device = "/dev/disk/by-uuid/e754208b-f961-48f3-8f00-dc636f3c646d";
#       preLVM = true;
#     };
#     home = {
#       device = "/dev/disk/by-label/870-evo";
#       preLVM = true;
#     };
#   };

#   services.gvfs.enable = true;
# }

{ }
