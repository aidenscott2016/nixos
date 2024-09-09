params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "emacs" params {
  environment.systemPackages = with pkgs; [
    nerdfonts
    coreutils
    fd
    clang
    nixfmt-classic
    emacs
    racket
    ripgrep
    nixpkgs-fmt
    nodePackages.prettier
  ];
}
