{ config, lib, pkgs, inputs, ... }:

{
  aiden.modules.common.enabled = true;
  environment.systemPackages = with pkgs; [
    inputs.disko.packages.x86_64-linux.disko
    git
  ];
}
