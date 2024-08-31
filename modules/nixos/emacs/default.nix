params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "emacs" params {
  environment.systemPackages = with pkgs; [ nixfmt-classic emacs racket ripgrep nixpkgs-fmt nodePackages.prettier ];
}
