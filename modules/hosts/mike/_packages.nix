{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    naps2
    antigravity-fhs
    gh
    ragenix
  ];
}
