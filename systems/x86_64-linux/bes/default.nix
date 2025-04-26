{
  config,
  inputs,
  lib,
  pkgs,
  systems,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
    ./portainer.nix
    inputs.agenix.nixosModules.default
  ];

  config =

    {
      services.iperf3.enable = true;
      services.iperf3.openFirewall = true;
      services.openssh.enable = true;
      services.openssh.openFirewall = true;
      security.sudo.wheelNeedsPassword = false;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      system.stateVersion = "23.11";

      services.cockpit.enable = true;
      services.cockpit.openFirewall = true;

      age.secrets.slskd.file = "${inputs.self.outPath}/secrets/slskd";
      services.slskd = {
        enable = true;
        domain = null;
        group = "video";
        settings = {
          shares.directories = [ "/media/t7/Music" ];
          directories = {
            incomplete = "/media/t7/Music/download/incomplete";
            downloads = "/media/t7/Music/download/complete";
          };

        };
        environmentFile = config.age.secrets.slskd.path;
      };
      users.users.slskd.extraGroups = [ "video" ];

      services.deluge = {
        enable = true;
        web = {
          enable = true;
          port = 8112;
        };
      };
      users.users.deluge.extraGroups = [ "video" ];

      services.bazarr = {
        enable = true;
        group = "video";
      };
      users.users.bazarr.extraGroups = [ "video" ];

      services.sonarr = {
        enable = true;
        group = "video";
      };
      users.users.sonarr.extraGroups = [ "video" ];

      nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-wrapped-6.0.36"
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
      ];

      services.radarr = {
        enable = true;
        group = "video";
      };
      users.users.radarr.extraGroups = [ "video" ];

      services.sabnzbd = {
        enable = true; # configFile = config.age.secrets.sabnzbd.path;
        group = "video";
      };
      users.users.sabnzbd.extraGroups = [ "video" ];

      users.users.aiden.extraGroups = [
        "video"
        "sadnzbd"
        "deluge"
      ];

      networking.firewall.allowedTCPPorts = [
        443
        5000
      ];

      aiden = {

        architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        programs.beets.enable = true;
        modules = {

          powermanagement.enable = true;
          cli-base.enable = true;
          locale.enable = true;
          reverseProxy = {
            enable = true;
            apps = [
              {
                name = "bazarr";
                port = 6767;
              }
              {
                name = "sonarr";
                port = 8989;
              }
              {
                name = "sab";
                port = 8080;
              }
              {
                name = "jellyfin";
                port = 8096;
              }
              {
                name = "portainer";
                port = 9000;
              }
              {
                name = "deluge";
                port = 8112;
              }
              {
                name = "radarr";
                port = 7878;
              }
              {
                name = "slskd";
                port = 5030;
              }
            ];
          };
          avahi.enable = true;
          jellyfin.enable = true;

          common = {
            domainName = "bes.sw1a1aa.uk";
            enable = true;
          };
          samba = {
            enable = true;
            shares.t7 = {
              path = "/media/t7";
              writable = "true";
            };
          };
        };
      };
      environment.systemPackages = with pkgs; [
        get_iplayer
        wol
        iperf3

      ];

      users.users.syncthing.extraGroups = [ "video" ];
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };

    };

}
