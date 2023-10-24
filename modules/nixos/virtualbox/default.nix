{ pkgs, ... }: {
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "aiden" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  #
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];
  users.users.aiden.extraGroups = [ "libvirtd" ];
}
