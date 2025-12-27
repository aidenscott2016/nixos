{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    services = {
      redshift.enable = true;
      geoclue2.enable = true;
    };
    location.provider = "geoclue2";
  };
}
