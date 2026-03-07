{ ... }:
{
  flake.modules.homeManager.fish =
    { ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          fish_vi_key_bindings
          source $__fish_data_dir/tools/web_config/sample_prompts/nim.fish
        '';
      };
    };
}
