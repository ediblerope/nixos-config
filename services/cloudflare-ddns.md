## Store your API key securely

Create a file outside your /etc/nixos directory to store your Cloudflare API token:

```bash
sudo mkdir -p /var/secrets
sudo nano /var/secrets/cloudflare-token
sudo chmod 600 /var/secrets/cloudflare-token
sudo chown root:root /var/secrets/cloudflare-token
```

This token is shared by both `cloudflare-ddns.nix` (DDNS updates) and `nginx.nix` (ACME wildcard cert via DNS-01 challenge).

## Get your Cloudflare API Token

Go to Cloudflare Dashboard → My Profile → API Tokens and create a token with:

- **Zone : Zone : Read**
- **Zone : DNS : Edit**

Both permissions are required — Zone:Read for ACME to locate the zone, DNS:Edit for DDNS updates and ACME challenge TXT records.

Copy the token to `/var/secrets/cloudflare-token`.
