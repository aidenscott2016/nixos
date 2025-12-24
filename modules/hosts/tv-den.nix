{ aiden, inputs, ... }:
{
  # Register tv-den host
  den.hosts.x86_64-linux.tv-den.users.aiden = { };

  # Define tv-den host aspect
  den.aspects.tv-den = {
    includes = [
      aiden.architecture
      aiden.locale
      aiden.gc
      aiden.cli-base
      aiden.nix
      aiden.ssh
      aiden.common
      aiden.avahi
      aiden.redshift
    ];

    nixos =
      { pkgs, lib, config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.disko.nixosModules.default
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ../../systems/x86_64-linux/tv-den/disk-config.nix
          ../../systems/x86_64-linux/tv-den/hardware-configuration.nix
        ];

        # Set architecture options
        aiden.architecture = {
          cpu = "intel";
          gpu = "intel";
        };

        # Set common options
        aiden.aspects.common = {
          domainName = "tv.sw1a1aa.uk";
          email = "aiden@tv.sw1a1aa.uk";
        };

        # Boot configuration
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Plymouth boot splash
        boot.plymouth = {
          enable = true;
          theme = "rings";
          themePackages = with pkgs; [
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "rings" ];
            })
          ];
        };

        # Silent boot
        boot.consoleLogLevel = 0;
        boot.initrd.verbose = false;
        boot.kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
          "i915.enable_guc=2"
        ];

        # Networking
        networking.hostName = "tv-den";
        networking.networkmanager.enable = true;

        # Desktop environment
        services.xserver.enable = true;
        services.desktopManager.plasma6.enable = true;
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = true;

        # Audio
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        # Hardware
        hardware.bluetooth.enable = true;
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
            intel-compute-runtime
          ];
        };

        # SSH
        services.openssh.openFirewall = true;

        # Security
        security.sudo.wheelNeedsPassword = false;

        # Home manager
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.aiden = {
          home.stateVersion = "23.11";
        };

        # Packages
        environment.systemPackages = with pkgs; [
          firefox
          lm_sensors
          htop
          moonlight-qt
        ];

        # Misc
        services.logrotate.checkConfig = false;

        system.stateVersion = "23.11";
      };
  };
}
