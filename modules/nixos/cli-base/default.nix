params@{ pkgs, lib, config, ... }:
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
  ];

}
