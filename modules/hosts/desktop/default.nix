{ den, nd, inputs, ... }: {
  # Host declaration with user
  den.hosts.x86_64-linux.desktop.users.aiden = {};

  # Host aspect
  den.aspects.desktop = {
    includes = [
      nd.common
      nd.locale
      nd.avahi
      nd.ssh
      nd.cli-base
      nd.nix
      nd.architecture
      nd.syncthing
      nd.darkman
      nd.printer
      nd.emacs
      nd.thunar
      nd.keyd
      nd.powermanagement
      nd.yubikey
      nd.appimage
      nd.pipewire
      nd.hardware-acceleration
      nd.ios
      nd.gaming
      nd.virtualisation
      nd.jovian
      den.provides.home-manager
    ];

    nixos = { config, lib, pkgs, ... }: {
      imports = [
        ./_packages.nix
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.disko.nixosModules.default
        ./_disk-configuration.nix
      ];

      facter.reportPath = ./facter.json;

      networking.hostName = "desktop";
      networking.interfaces.enp6s0.wakeOnLan.enable = true;
      networking.networkmanager.enable = true;

      # Desktop services
      programs.nm-applet.enable = true;
      services = {
        envfs.enable = true;
        blueman.enable = true;
        tailscale.enable = true;
        mullvad-vpn.enable = true;
        gvfs.enable = true;
      };

      systemd.network.wait-online.enable = false;
      hardware.bluetooth.enable = true;

      services.xserver.enable = lib.mkForce false;
      services.open-webui = {
        enable = true;
        openFirewall = true;
        host = "0";
      };
      services.ollama = {
        enable = true;
        openFirewall = true;
        host = "0";
      };

      narrowdivergent = {
        architecture = {
          cpu = "amd";
          gpu = "amd";
        };
        aspects = {
          powermanagement.enable = false;
          gaming = {
            games.oblivionSync.enable = true;
            steam.enable = true;
            moonlight.client.enable = true;
            moonlight.server.enable = true;
          };
        };
      };

      system.stateVersion = "22.05";

      boot.loader.systemd-boot.enable = true;

      boot.kernelParams = [ "ip=dhcp" ];
      boot.initrd = {
        availableKernelModules = [ "r8169" ];
        network = {
          enable = true;
          ssh = {
            enable = true;
            port = 22;
            authorizedKeys = [ config.narrowdivergent.aspects.common.publicKey ];
            hostKeys = [ "/etc/secrets/initrd/ssh_host_key" ];
            shell = "/bin/cryptsetup-askpass";
          };
        };
      };

      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      imports = [
        nd.home.bash
        nd.home.darkman
        nd.home.desktop
        nd.home.easyeffects
        nd.home.firefox
        nd.home.git
        nd.home.gpg-agent
        nd.home.ideavim
        nd.home.ssh
        nd.home.tmux
        nd.home.vim
        nd.home.xdg-portal
      ];
    };
  };
}
