# services/nginx.nix — Native nginx reverse proxy with ACME wildcard cert
{ config, lib, ... }:
let
  # Authelia forward-auth snippet injected into protected locations
  autheliaAuthConfig = ''
    auth_request /internal/authelia/authz;
    auth_request_set $target_url $scheme://$http_host$request_uri;
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    error_page 401 =302 https://auth.nordhammer.it/?rd=$target_url;
  '';

  # Internal location that queries Authelia's verification endpoint
  autheliaLocation = {
    "/internal/authelia/authz" = {
      proxyPass = "http://127.0.0.1:9091/api/authz/forward-auth";
      extraConfig = ''
        internal;
        proxy_set_header X-Original-Method $request_method;
        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
        proxy_set_header X-Forwarded-Method $request_method;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-URI $request_uri;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Content-Length "";
        proxy_set_header Connection "";
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
        # Wait 30s after creating the TXT record before asking LE to validate
        extraLegoRunFlags = [ "--dns.propagation-wait" "30s" ];
        extraLegoRenewFlags = [ "--dns.propagation-wait" "30s" ];
        credentialFiles = {
          "CF_DNS_API_TOKEN_FILE" = "/var/secrets/cloudflare-token";
        };
      };
    };

    users.users.nginx.extraGroups = [ "acme" ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # File-based access log for fail2ban
      appendHttpConfig = ''
        access_log /var/log/nginx/access.log;
      '';

      virtualHosts = {
        # --- Authelia portal (not behind auth itself) ---
        "auth.nordhammer.it" = proxy 9091;

        # --- Media ---
        "jellyfin.nordhammer.it" = proxy 8096;
        "bazarr.nordhammer.it"  = proxy 6767;
        "sonarr.nordhammer.it"  = proxy 8989;
        "radarr.nordhammer.it"  = proxy 7878;

        # --- Downloads ---
        "prowlarr.nordhammer.it" = proxy 9696;
        "torrent.nordhammer.it"  = proxy 8080;

        # --- Other ---
        "games.nordhammer.it"  = proxy 8787;
        "search.nordhammer.it" = proxy 8087;

        # --- Protected by Authelia ---
        "camera.nordhammer.it"   = protectedProxy 1984;
        "homepage.nordhammer.it" = protectedProxy 8082;
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
