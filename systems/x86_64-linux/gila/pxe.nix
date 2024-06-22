{ config, inputs, lib, pkgs, systems, ... }:
let
  build = inputs.self.nixosConfigurations.pxe.config.system.build;
in
{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true;
    port = 9080;
    mode = "boot";
    # kernel = "${build.kernel}/bzImage";
    # initrd = "${build.netbootRamdisk}/initrd";
    # cmdLine = "init=${build.toplevel}/init loglevel=4";
    debug = true;
  };
}
