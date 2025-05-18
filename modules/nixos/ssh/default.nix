params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib.aiden;
enableableModule "ssh" params {
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.aiden.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCoq4Vfco724r3Ogg0s2fijnu9GtDsDW/e5JsKAQOzf"
  ];
}
