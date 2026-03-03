{ ... }:
{
  flake.modules.nixos.openttd =
    { pkgs, ... }:
    {
      config = {
        environment.systemPackages = with pkgs; [ openttd ];
      };
    };
}
