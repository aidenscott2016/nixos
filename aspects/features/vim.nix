{ lib, ... }:
{
  flake.modules.homeManager.vim = { config, ... }: {
    home.file.".vimrc".source = ./vimrc;
  };
}
