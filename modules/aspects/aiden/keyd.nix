{
  aiden.keyd.nixos = {
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              # Maps capslock to escape when pressed and control when held
              capslock = "overloadt(control, esc, 150)";
            };
            otherlayer = { };
          };
          extraConfig = "";
        };
      };
    };
  };
}
