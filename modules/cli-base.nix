inputs@{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    inputs.maimpick.packages."${system}".maimpick
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
