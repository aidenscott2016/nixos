{
  aiden.redshift.nixos = {
    services.redshift.enable = true;
    services.geoclue2.enable = true;
    location.provider = "geoclue2";
  };
}
