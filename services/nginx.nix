# services/nginx.nix — Native nginx reverse proxy with ACME wildcard cert
{ config, lib, ... }:
let
  # Authelia forward-auth snippet injected into protected locations
  autheliaAuthConfig = ''
    auth_request /authelia;
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $email $upstream_http_remote_email;
    error_page 401 =302 https://auth.nordhammer.it/?rd=$scheme://$http_host$request_uri;
  '';

  # Internal location that queries Authelia's verification endpoint
  autheliaLocation = {
    "/authelia" = {
      proxyPass = "http://127.0.0.1:9091/api/verify";
      extraConfig = ''
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
        proxy_set_header X-Forwarded-Method $request_method;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Uri $request_uri;
        proxy_set_header X-Forwarded-For $remote_addr;
      '';
    };
  };

  ssl = {
    useACMEHost = "nordhammer.it";
    forceSSL = true;
  };

  # Simple reverse proxy vhost
  proxy = port: ssl // {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };

  # Reverse proxy protected by Authelia forward auth
  protectedProxy = port: ssl // {
    locations = autheliaLocation // {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        extraConfig = autheliaAuthConfig;
      };
    };
  };
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    # Wildcard TLS cert via Cloudflare DNS-01 challenge
    security.acme = {
      acceptTerms = true;
      defaults.email = "fredrik@nordhammer.it";
      certs."nordhammer.it" = {
        domain = "*.nordhammer.it";
        extraDomainNames = [ "nordhammer.it" ];
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = "/var/secrets/cloudflare-token";
        };
      };
    };

    # Give Cloudflare authoritative NS more time to propagate TXT records
    systemd.services."acme-order-renew-nordhammer.it".environment.CLOUDFLARE_PROPAGATION_TIMEOUT = "600";

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # File-based access log for fail2ban + fix proxy_headers_hash warning
      appendHttpConfig = ''
        proxy_headers_hash_max_size 1024;
        access_log /var/log/nginx/access.log;
      '';

      virtualHosts = {
        # --- Unprotected (own auth, or by design) ---
        "auth.nordhammer.it"     = proxy 9091;  # Authelia portal itself
        "jellyfin.nordhammer.it" = proxy 8096;  # streaming to external clients

        # --- Protected by Authelia ---
        "bazarr.nordhammer.it"   = protectedProxy 6767;
        "sonarr.nordhammer.it"   = protectedProxy 8989;
        "radarr.nordhammer.it"   = protectedProxy 7878;
        "prowlarr.nordhammer.it" = protectedProxy 9696;
        "torrent.nordhammer.it"  = protectedProxy 8080;
        "camera.nordhammer.it"   = protectedProxy 1984;
        "homepage.nordhammer.it" = protectedProxy 8082;
        "7dtd.nordhammer.it"     = protectedProxy 8090;
        "adguard.nordhammer.it"  = protectedProxy 3000;

        # --- Local-only: serves update history JSON to Homepage's customapi widget ---
        "homepage-updates.local" = {
          listen = [ { addr = "127.0.0.1"; port = 8083; } ];
          locations."/".root = "/var/lib/homepage-updates";
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
