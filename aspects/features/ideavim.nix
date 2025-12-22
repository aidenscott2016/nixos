{ lib, ... }:
{
  flake.homeManagerModules.ideavim = { ... }: {
    home.file.".ideavimrc".source = ./ideavimrc;
  };
}
