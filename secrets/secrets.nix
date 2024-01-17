let
  aiden =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN";
  users = [ aiden ];

  lovelace =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHN4Z6+j8AU0Qiywv8sTjlG0UlY+ZAUzLWMSnqeY5U0f";
  systems = [ lovelace ];
in
{ "secret1.age".publicKeys = [ aiden lovelace ]; "lego-credentials.age".publicKeys = [ aiden ]; }
