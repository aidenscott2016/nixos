{ config, pkgs, lib, myModulesPath, inputs, ... }:
with lib.aiden; {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./autorandr
    inputs.dwm.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [ inputs.disko.packages.x86_64-linux.disko docker-compose ];
  aiden = {
    modules = {
      avahi = enabled;
      common = enabled;
      ios = enabled;
      redshift = enabled;
      printer = enabled;
      ssh = enabled;
      gc = enabled;
      cli-base = enabled;
      desktop = enabled;
      multimedia = enabled;
      emacs = enabled;
      steam.enabled = false;
    };
    programs = { openttd.enabled = true; };
  };

  system.stateVersion = "22.05";

  services.openssh.openFirewall = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.aiden = { };

  boot = {
    supportedFilesystems = [ "ntfs" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
      };

    };
  };

  programs.nm-applet.enable = true;

  services = {
    fstrim.enable = true;
    upower.enable = true;
    auto-cpufreq.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    xserver = { enable = true; libinput.enable = true; };
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = 1;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 85;
        START_CHARGE_THRESH_BAT1 = 50;
        STOP_CHARGE_THRESH_BAT1 = 85;
      };

    };

    tailscale.enable = true;
    gvfs.enable = true;

  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "locutus";
    networkmanager.enable = true;
  };

  virtualisation.podman = { enable = true; dockerCompat = true; };
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
    port = 9002;
  };

  age.secrets.cloudflareToken.file = "${inputs.self.outPath}/secrets/cf-token.age";
  security.acme = {
    acceptTerms = true;
    defaults.email = "aiden@oldstreetjournal.co.uk";
    certs = {
      "locutus.sw1a1aa.uk" = {
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.cloudflareToken.path;
        dnsResolver = "1.1.1.1:53";
      };
    };
  };

  users.users.traefik.extraGroups = [ "acme" "podman" ]; # to read acme folder
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      log = { level = "debug"; };
      accessLog = { };
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
      providers.docker = {
        exposedByDefault = false;
        endpoint = "unix:///var/run/podman/podman.sock";
      };
      api.dashboard = true;
      api.insecure = true;
      entrypoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure.address = ":443";
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          metrics = {
            service = "nodeexporter";
            entrypoints = "websecure";
            rule = "Host(`locutus.sw1a1aa.uk`) && PathPrefix(`/metrics/node`)";
            tls = true;
            middlewares = "metricsRewrite";
          };
        };
        middlewares = {
          metricsRewrite = {
            replacepath.path = "/metrics";
          };
        };
        services = {
          nodeexporter = {
            loadbalancer = {
              servers = [{ url = "http://locutus.sw1a1aa.uk:${toString config.services.prometheus.exporters.node.port}"; }];
              #servers = [{ url = "http://locutus.sw1a1aa.uk:9999"; }];
            };
          };
        };
      };

      tls = {
        stores.default = {
          defaultCertificate = {
            certFile = "/var/lib/acme/locutus.sw1a1aa.uk/fullchain.pem";
            keyFile = "/var/lib/acme/locutus.sw1a1aa.uk/key.pem";
          };
        };
      };
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs;[ mesa amdvlk libva ];
    driSupport = true;
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
