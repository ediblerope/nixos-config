1. Store your API key securely
Create a file outside your /etc/nixos directory to store your Cloudflare API token:
bashsudo mkdir -p /var/secrets
sudo nano /var/secrets/cloudflare-token
Put your Cloudflare API token in this file, then set appropriate permissions:
bashsudo chmod 600 /var/secrets/cloudflare-token
sudo chown root:root /var/secrets/cloudflare-token


3. Get your Cloudflare API Token
If you haven't created one yet:

Go to Cloudflare Dashboard → My Profile → API Tokens
Create a token with Zone:DNS:Edit permissions for your specific zone
Copy the token to /var/secrets/cloudflare-token
