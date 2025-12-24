{ pkgs, ... }:
{
  den.aspects.cli-base = {
    nixos = {
      environment.systemPackages = with pkgs; [
        fish
        vim
        wget
        emacs
        git
        pass
        tmux
        file
        psmisc # killall etal
        ncdu
        unzip
        p7zip
        gnupg
        iperf
        dnsutils # nslookup
        ranger
        sshfs

        # nixos/modules/profiles/base.nix
        w3m-nographics # needed for the manual anyway
        testdisk # useful for repairing boot problems
        ms-sys # for writing Microsoft boot sectors / MBRs
        efibootmgr
        efivar
        parted
        gptfdisk
        ddrescue
        ccrypt
        cryptsetup # needed for dm-crypt volumes

        # Some text editors.
        (vim.customize {
          name = "vim";
          vimrcConfig.packages.default = {
            start = [ vimPlugins.vim-nix ];
          };
          vimrcConfig.customRC = "syntax on";
        })

        # Some networking tools.
        fuse
        fuse3
        sshfs-fuse
        socat
        screen
        tcpdump

        # Hardware-related tools.
        sdparm
        hdparm
        smartmontools # for diagnosing hard disks
        pciutils
        usbutils
        nvme-cli

        # Some compression/archiver tools.
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
