{ lib, ... }:
{
  flake.homeManagerModules.vim = { config, ... }: {
    home.file.".vimrc".source = ./vimrc;
  };
}
