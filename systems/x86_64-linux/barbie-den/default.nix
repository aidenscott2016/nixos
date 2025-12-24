# Den-style host configuration for barbie-den
# This file provides host-specific configuration that gets merged with the den aspect
{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.nixos-hardware.nixosModules.gpd-pocket-3
  ];
}
