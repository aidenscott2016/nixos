{ ... }:
{
  aiden.home.vim.nixos = { config, ... }: {
    home-manager.users.aiden.home.file.".vimrc".source = config.home-manager.users.aiden.lib.file.mkOutOfStoreSymlink ./vim/vimrc;
  };
}
