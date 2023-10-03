{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "lovelace";
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
