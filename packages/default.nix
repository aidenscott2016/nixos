{ pkgs }:
{
  beetcamp = pkgs.callPackage ./beetcamp { };
  # rich-tables appears to be empty, skip it
}
