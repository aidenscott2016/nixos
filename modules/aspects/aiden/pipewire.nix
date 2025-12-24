{
  aiden.pipewire.nixos =
    { pkgs, ... }:
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };

      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [ easyeffects ];
    };
}
