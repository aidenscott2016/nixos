{ ... }:
{
  flake.modules.nixos.uptime-kuma =
    { ... }:
    {
      services.uptime-kuma = {
        enable = true;
        settings.PORT = "3001";
      };

      aiden.modules.reverseProxy.apps = [
        { name = "status"; port = 3001; }
      ];
    };
}
