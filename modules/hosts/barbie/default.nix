{ den, nd, inputs, ... }: {
  # Host declaration with home-manager integration
  den.hosts.x86_64-linux.barbie.users.aiden = {};

  # Host aspect
  den.aspects.barbie = {
    includes = [
      nd.common
      nd.ssh
      nd.locale
      nd.avahi
      nd.barbie-hardware
      den.provides.home-manager
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

    nixos = { config, pkgs, lib, ... }: {
      imports = [
        inputs.disko.nixosModules.default
        inputs.nixos-hardware.nixosModules.gpd-pocket-3
      ];

      # Disko configuration
      disko.devices = {
        disk = {
          vdb = {
            type = "disk";
            device = "/dev/nvme0n1";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "500M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "defaults" ];
                  };
                };
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypted";
                    content = {
                      type = "lvm_pv";
                      vg = "pool";
                    };
                  };
                };
              };
            };
          };
        };
        lvm_vg = {
          pool = {
            type = "lvm_vg";
            lvs = {
              root = {
                size = "75G";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [ "defaults" ];
                };
              };
              swap = {
                size = "8G";
                content = { type = "swap"; };
              };
              home = {
                size = "+100%FREE";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/home";
                };
              };
              raw = {
                size = "10M";
              };
            };
          };
        };
      };

      # Host-specific config
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "barbie";
      networking.networkmanager.enable = true;

      services.xserver.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };
      services.openssh.openFirewall = true;
      services.desktopManager.plasma6.enable = true;

      security.sudo.wheelNeedsPassword = false;
      system.stateVersion = "24.05";

      environment.systemPackages = [ pkgs.maliit-keyboard ];

      # Module options (using new namespace)
      narrowdivergent.aspects.common = {
        domainName = "narrowdivergent.com";
        email = "aiden@narrowdivergent.com";
      };
    };
  };
}
