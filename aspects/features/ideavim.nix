{ lib, ... }:
{
  flake.modules.homeManager.ideavim = { ... }: {
    home.file.".ideavimrc".source = ./ideavimrc;
  };
}
