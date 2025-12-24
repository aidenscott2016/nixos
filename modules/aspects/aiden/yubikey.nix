{
  aiden.yubikey.nixos =
    { pkgs, ... }:
    {
      services.pcscd.enable = true;
      security.polkit.enable = true;
      environment.systemPackages = with pkgs; [ yubikey-manager ];
    };
}
