{ ... }:
{
  flake.modules.homeManager.ideavim =
    { config, lib, pkgs, ... }:
    {
      home.file.".ideavimrc".source = ./ideavimrc;
    };
}
