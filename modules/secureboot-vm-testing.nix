{ ... }:
{
  flake.modules.nixos.secureboot-vm-testing =
    { ... }:
    {
      virtualisation.libvirtd.qemu.swtpm.enable = true;
    };
}
