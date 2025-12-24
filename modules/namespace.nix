{ inputs, den, ... }:
{
  imports = [ (inputs.den.namespace "aiden" true) ];
  _module.args.__findFile = den.lib.__findFile;
}
