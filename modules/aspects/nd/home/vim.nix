{ nd, ... }: {
  nd.home.vim = {
    homeManager = { config, ... }: {
      home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink ../../../_home/vim/vimrc;
    };
  };
}
