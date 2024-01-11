params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "emacs" params {
  environment.systemPackages = with pkgs; [ emacs racket ripgrep nixpkgs-fmt ];
}
