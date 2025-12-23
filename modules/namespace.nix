{ inputs, ... }:
{
  imports = [ inputs.denful.flakeModule ];

  denful.namespaces = {
    aiden = {
      dir = ./aspects;
    };
  };
}
