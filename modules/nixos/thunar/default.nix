params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "thunar" params {

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  # enables unzipping
  environment.systemPackages = with pkgs; [ file-roller ];

}
