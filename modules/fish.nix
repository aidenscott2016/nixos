{ ... }:
{
  flake.modules.homeManager.fish =
    { ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = "fish_vi_key_bindings";
      };
    };
}
