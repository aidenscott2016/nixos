params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "redshift" params {
  services = {
    redshift.enable = true;
    geoclue2.enable = true;
  };
  location.provider = "geoclue2";
}
