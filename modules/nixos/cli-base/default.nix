params@{ pkgs, lib, config, modulesPath,  ... }:
with lib.aiden;
enableableModule "cli-base" params {
  environment.systemPackages = with pkgs; [
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
    pkgs.w3m-nographics # needed for the manual anyway
    pkgs.testdisk # useful for repairing boot problems
    pkgs.ms-sys # for writing Microsoft boot sectors / MBRs
    pkgs.efibootmgr
    pkgs.efivar
    pkgs.parted
    pkgs.gptfdisk
    pkgs.ddrescue
    pkgs.ccrypt
    pkgs.cryptsetup # needed for dm-crypt volumes

    # Some text editors.
    (pkgs.vim.customize {
      name = "vim";
      vimrcConfig.packages.default = {
        start = [ pkgs.vimPlugins.vim-nix ];
      };
      vimrcConfig.customRC = "syntax on";
    })

    # Some networking tools.
    pkgs.fuse
    pkgs.fuse3
    pkgs.sshfs-fuse
    pkgs.socat
    pkgs.screen
    pkgs.tcpdump

    # Hardware-related tools.
    pkgs.sdparm
    pkgs.hdparm
    pkgs.smartmontools # for diagnosing hard disks
    pkgs.pciutils
    pkgs.usbutils
    pkgs.nvme-cli

    # Some compression/archiver tools.
    pkgs.unzip
    pkgs.zip
  ];
}

