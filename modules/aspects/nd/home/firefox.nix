{ nd, ... }: {
  nd.home.firefox = {
    homeManager = { pkgs, inputs, ... }:
    let
      addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.file.".tridactylrc".source = ../../../_home/firefox/tridactylrc;
      programs.firefox = {
        enable = true;
        package = pkgs.firefox.override {
          cfg = {
            speechSynthesisSupport = false;
          };
        };
        profiles.aiden = {
          extensions = with addons; [
            sponsorblock
            tridactyl
            ublock-origin
            darkreader
            tree-style-tab
            bitwarden
          ];
          settings = {
            "privacy.resistFingerprinting" = false;
            "browser.compactmode.show" = true;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "browser.uidensity" = 1;
            "browser.download.autohideButton" = false;
          };
        };
      };
    };
  };
}
