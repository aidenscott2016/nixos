{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ emacs racket ripgrep nixfmt ];
}
