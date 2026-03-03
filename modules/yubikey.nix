{ ... }:
{
  flake.modules.nixos.yubikey =
    { pkgs, lib, config, ... }:
    {
      services.pcscd.enable = true;
      security.polkit.enable = true;
      environment.systemPackages = with pkgs; [ yubikey-manager ];
    };
}
