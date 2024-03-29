params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "desktop" params {

  # services.xserver.dpi = 180;
  services.mullvad-vpn.enable = true;
  #  services.xserver.desktopManager.xfce.enable = true;
  #  nixpkgs.config.permittedInsecurePackages = [ "googleearth-pro-7.3.4.8248" ];

  #needed for extracting files in thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  environment.systemPackages = with pkgs; [ gnome.file-roller ];

}
