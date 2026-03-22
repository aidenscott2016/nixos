let
  aiden = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN";
  users = [ aiden ];
  locutus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9g9o59uCL408pLv7RQglyvnoAHSwuitICOTVBu70X5";
  lovelace = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHN4Z6+j8AU0Qiywv8sTjlG0UlY+ZAUzLWMSnqeY5U0f";
  gila = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9nT33O30eofxYEcnJRVunFvFmOB9VqPDWC9EC77+Lz";
  thoth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuers0/aJpKmaxeD0CPHbQ6O422fkVO4i3JTLTtbW4I";
  bes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzPVRkO3VnKNm7cMAQozOPyOMIRuA4/gmkvZSaWRWfK";
in
{
  "secret1.age".publicKeys = [
    aiden
    lovelace
  ];
  "lego-credentials.age".publicKeys = [ aiden ];
  "mosquitto-pass.age".publicKeys = [
    aiden
    gila
  ];
  "gila-tailscale-authkey".publicKeys = [ gila ];
  "thoth-tailscale-authkey".publicKeys = [ thoth ];
  "cf-token.age".publicKeys = [
    aiden
    gila
    locutus
  ];
  "slskd".publicKeys = [
    aiden
    bes
  ];
  "restic-b2-env.age".publicKeys = [
    aiden
    bes
  ];
  "restic-b2-password.age".publicKeys = [
    aiden
    bes
  ];
  "opencode-env.age".publicKeys = [
    aiden
    bes
  ];
  "grafana-admin-password.age".publicKeys = [
    aiden
    bes
  ];
  "uptime-kuma-password.age".publicKeys = [ aiden ];
  "authelia-jwt-secret.age".publicKeys = [ aiden bes ];
  "authelia-session-secret.age".publicKeys = [ aiden bes ];
  "authelia-storage-encryption-key.age".publicKeys = [ aiden bes ];
  "authelia-oidc-hmac-secret.age".publicKeys = [ aiden bes ];
  "authelia-oidc-issuer-private-key.age".publicKeys = [ aiden bes ];
  "crowdsec-enroll-key.age".publicKeys = [ aiden gila ];
  "authelia-oidc-client-grafana.age".publicKeys = [ aiden bes ];
  "authelia-oidc-client-immich.age".publicKeys = [ aiden bes ];
  "authelia-oidc-client-paperless.age".publicKeys = [ aiden bes ];
  "authelia-oidc-client-portainer.age".publicKeys = [ aiden bes ];
  "authelia-users.age".publicKeys = [ aiden bes ];
}
