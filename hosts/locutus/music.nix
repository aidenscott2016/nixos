inputs@{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nicotine-plus
    (beets.override
      {
        pluginOverrides = {
          copyartifacts = { enable = true; propagatedBuildInputs = [ beetsPackages.copyartifacts ]; };
        };
      })
  ];
} 
  
