{ ... }:
{
  flake.modules.nixos.initrd-ssh =
    { config, ... }:
    {
      boot.initrd = {
        systemd.enable = true;
        systemd.network.enable = true;
        network.ssh = {
          enable = true;
          authorizedKeys = config.users.users.aiden.openssh.authorizedKeys.keys;
        };
      };
    };
}
