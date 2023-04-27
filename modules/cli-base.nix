inputs@{ config, pkgs, ... }: {
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
  ];

}
