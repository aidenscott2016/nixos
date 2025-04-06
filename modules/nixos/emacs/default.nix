params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "emacs" params {
  environment.systemPackages = with pkgs; [
    coreutils
    fd
    clang
    nixfmt-rfc-style
    emacs
    racket
    ripgrep
    nixpkgs-fmt
    nodePackages.prettier
    nixd
    nil
  ];
}
