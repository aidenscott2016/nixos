{ lib, pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowPing = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "aiden@oldstreetjournal.co.uk";
  services = {
    nginx.enable = true;
    nginx.virtualHosts."jellyfin.aidenscott.dev" = {
      addSSL = true;
      enableACME = true;
      extraConfig = ''
        ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
          client_max_body_size 20M;

          # use a variable to store the upstream proxy
          # in this example we are using a hostname which is resolved via DNS
          # (if you aren't using DNS remove the resolver line and change the variable to point to an IP address e.g `set $jellyfin 127.0.0.1`)
          set $jellyfin 127.0.0.1;

          #ssl_certificate /etc/letsencrypt/live/DOMAIN_NAME/fullchain.pem;
          #ssl_certificate_key /etc/letsencrypt/live/DOMAIN_NAME/privkey.pem;
          #include /etc/letsencrypt/options-ssl-nginx.conf;
          #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
          #add_header Strict-Transport-Security "max-age=31536000" always;
          #ssl_trusted_certificate /etc/letsencrypt/live/DOMAIN_NAME/chain.pem;
          #ssl_stapling on;
          #ssl_stapling_verify on;

          # Security / XSS Mitigation Headers
          # NOTE: X-Frame-Options may cause issues with the webOS app
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Content-Type-Options "nosniff";

          # Content Security Policy
          # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
          # Enforces https content and restricts JS/CSS to origin
          # External Javascript (such as cast_sender.js for Chromecast) must be whitelisted.
          # NOTE: The default CSP headers may cause issues with the webOS app
          #add_header Content-Security-Policy "default-src https: data: blob: http://image.tmdb.org; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com/cv/js/sender/v1/cast_sender.js https://www.gstatic.com/eureka/clank/95/cast_sender.js https://www.gstatic.com/eureka/clank/96/cast_sender.js https://www.gstatic.com/eureka/clank/97/cast_sender.js https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'";

          location = / {
              return 302 http://$host/web/;
              #return 302 https://$host/web/;
          }

          location / {
              # Proxy main Jellyfin traffic
              proxy_pass http://$jellyfin:8096;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;

              # Disable buffering when the nginx proxy gets very resource heavy upon streaming
              proxy_buffering off;
          }

          # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
          location = /web/ {
              # Proxy main Jellyfin traffic
              proxy_pass http://$jellyfin:8096/web/index.html;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
          }

          location /socket {
              # Proxy Jellyfin Websockets traffic
              proxy_pass http://$jellyfin:8096;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
          }
      '';
    };
    jellyfin = {
      user = "aiden";
      enable = true;
      openFirewall = true;
    };
  };
}
  

