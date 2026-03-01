{ inputs, config, ... }:
{
  flake.modules.nixos.home-manager =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.aiden.imports =
        builtins.attrValues (config.flake.modules.homeManager or {});
    };
}
