{ lib, ... }:
{
  flake.nixosModules.cli-base = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.cli-base;
    in {
      options.aiden.modules.cli-base.enable = mkEnableOption "cli-base";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          fish
          vim
          wget
          emacs
          git
          pass
          tmux
          file
          psmisc
          ncdu
          unzip
          p7zip
          gnupg
          iperf
          dnsutils
          ranger
          sshfs

          w3m-nographics
          testdisk
          ms-sys
          efibootmgr
          efivar
          parted
          gptfdisk
          ddrescue
          ccrypt
          cryptsetup

          (vim.customize {
            name = "vim";
            vimrcConfig.packages.default = {
              start = [ vimPlugins.vim-nix ];
            };
            vimrcConfig.customRC = "syntax on";
          })

          fuse
          fuse3
          sshfs-fuse
          socat
          screen
          tcpdump

          sdparm
          hdparm
          smartmontools
          pciutils
          usbutils
          nvme-cli

          unzip
          zip

          powertop
          acpi
          libva-utils
          wol
          htop
        ];
      };
    };
}
