{ inputs, ... }:
{
  flake.modules.nixos.authelia =
    { config, pkgs, ... }:
    let
      usersFile = pkgs.writeText "authelia-users.yml" (builtins.readFile ./_authelia-users.yml);
    in
    {
      age.secrets.authelia-jwt-secret = {
        file = "${inputs.self.outPath}/secrets/authelia-jwt-secret.age";
        owner = "authelia-main";
        mode = "0400";
      };
      age.secrets.authelia-session-secret = {
        file = "${inputs.self.outPath}/secrets/authelia-session-secret.age";
        owner = "authelia-main";
        mode = "0400";
      };
      age.secrets.authelia-storage-encryption-key = {
        file = "${inputs.self.outPath}/secrets/authelia-storage-encryption-key.age";
        owner = "authelia-main";
        mode = "0400";
      };
      age.secrets.authelia-oidc-hmac-secret = {
        file = "${inputs.self.outPath}/secrets/authelia-oidc-hmac-secret.age";
        owner = "authelia-main";
        mode = "0400";
      };
      age.secrets.authelia-oidc-issuer-private-key = {
        file = "${inputs.self.outPath}/secrets/authelia-oidc-issuer-private-key.age";
        owner = "authelia-main";
        mode = "0400";
      };

      services.authelia.instances.main = {
        enable = true;

        secrets = {
          jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
          sessionSecretFile = config.age.secrets.authelia-session-secret.path;
          storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
          oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac-secret.path;
          oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-issuer-private-key.path;
        };

        settings = {
          server.address = "tcp://127.0.0.1:9092/";

          log = {
            format = "json";
            level = "info";
            keep_stdout = true;
          };

          authentication_backend.file = {
            path = "/var/lib/authelia-main/users.yml";
            watch = true;
          };

          session = {
            cookies = [
              {
                domain = "sw1a1aa.uk";
                authelia_url = "https://auth.sw1a1aa.uk";
                name = "authelia_session";
                expiration = "1h";
                inactivity = "5m";
              }
            ];
          };

          storage.local.path = "/var/lib/authelia-main/db.sqlite3";

          notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

          access_control = {
            default_policy = "two_factor";
            rules = [
              {
                domain = "auth.sw1a1aa.uk";
                policy = "bypass";
              }
              {
                domain = "*.sw1a1aa.uk";
                networks = [ "10.0.0.0/8" "100.64.0.0/10" ];
                policy = "one_factor";
              }
              {
                domain = [ "portainer.sw1a1aa.uk" "grafana.sw1a1aa.uk" ];
                policy = "two_factor";
              }
            ];
          };

          identity_providers.oidc = {
            clients = [
              {
                client_id = "grafana";
                client_name = "Grafana";
                client_secret = "$pbkdf2-sha512$310000$xVB4ZGjHaHoiOf3w3P.Jcw$8HNvGaASzM3HjPLDdjxQkKVYtPeUfjym6MZ8hHAlWZcjCjqpc4W/jS49MqVfgyO72UUbaRcTgOVzsJkaI25LAA";
                redirect_uris = [ "https://grafana.sw1a1aa.uk/login/generic_oauth" ];
                scopes = [ "openid" "email" "profile" "groups" ];
                grant_types = [ "authorization_code" ];
                response_types = [ "code" ];
                token_endpoint_auth_method = "client_secret_basic";
              }
              {
                client_id = "immich";
                client_name = "Immich";
                client_secret = "$pbkdf2-sha512$310000$4/F4.R4pb.TtTOdy/y6Zmw$HBSM0PZzDU4TlHlrYF5A/roykv520HQpMIu2IEmwBkWZDQ/rY7aAgS4H/8V93Zs.mBVpLt6fzDw5WTYCChHotg";
                redirect_uris = [
                  "https://photos.sw1a1aa.uk/auth/login"
                  "https://photos.sw1a1aa.uk/user-settings"
                  "app.immich:///oauth-callback"
                ];
                scopes = [ "openid" "email" "profile" ];
                grant_types = [ "authorization_code" ];
                response_types = [ "code" ];
                token_endpoint_auth_method = "client_secret_post";
              }
              {
                client_id = "paperless";
                client_name = "Paperless";
                client_secret = "$pbkdf2-sha512$310000$k.U/BhlUa7BZo/MtH3QYNQ$MoK3SjgVBZ6CF5xfwVdDRcTZk73pUvDbg1r2apif2fq9.JCO9vcdZpFgnPOVQWgj0Ow1CjS1mZn1JArt9.IKHg";
                redirect_uris = [ "https://paperless.sw1a1aa.uk/accounts/oidc/authelia/login/callback/" ];
                scopes = [ "openid" "email" "profile" ];
                grant_types = [ "authorization_code" ];
                response_types = [ "code" ];
                token_endpoint_auth_method = "client_secret_basic";
              }
              {
                client_id = "portainer";
                client_name = "Portainer";
                client_secret = "$pbkdf2-sha512$310000$FYmUbg61Ow52TXxeXGHFeQ$lypdWyO3Th25qJLkQjYvf1bFR3HRWJktX5kyzJLUynot1WJk6dYhfYMm43kFSdB4q7SxxGVCHow2knSLlupdew";
                redirect_uris = [ "https://portainer.sw1a1aa.uk" ];
                scopes = [ "openid" "email" "profile" "groups" ];
                grant_types = [ "authorization_code" ];
                response_types = [ "code" ];
                token_endpoint_auth_method = "client_secret_basic";
              }
            ];
          };

          telemetry.metrics = {
            enabled = true;
            address = "tcp://127.0.0.1:9959/";
          };
        };
      };

      systemd.services.authelia-main.after = [ "agenix.service" ];

      systemd.tmpfiles.rules = [
        "C /var/lib/authelia-main/users.yml 0600 authelia-main authelia-main - ${usersFile}"
      ];

      aiden.modules.reverseProxy.apps = [
        { name = "auth"; port = 9092; auth = false; }
      ];
    };
}
