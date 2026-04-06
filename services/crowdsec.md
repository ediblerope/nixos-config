# CrowdSec Setup

CrowdSec runs as a Docker (OCI) container on FredOS-Mediaserver. The firewall
bouncer runs as a native NixOS service and talks to the containerised LAPI over
localhost:8080.

## Why Docker?

The `crowdsec` package in nixpkgs unstable is incomplete — the NixOS module
does not reliably set up the LAPI and hub collections. The official CrowdSec
Docker image is well maintained and always up to date.

## Architecture

```
[journald / log sources]
        |
   [CrowdSec LAPI]          ← Docker container (port 8080 on localhost)
        |
[firewall-bouncer]          ← Native NixOS service (nftables/iptables)
```

## Initial Setup (first deploy)

After running `nixos-rebuild switch`, the CrowdSec container will be running
but the firewall bouncer has no API key yet.

**1. Generate a bouncer API key:**

```bash
docker exec crowdsec cscli bouncers add firewall-bouncer
```

Copy the key printed to stdout — it is only shown once.

**2. Store the key on the machine:**

```bash
sudo mkdir -p /var/lib/secrets
echo -n "PASTE_KEY_HERE" | sudo tee /var/lib/secrets/crowdsec-bouncer-key
sudo chmod 600 /var/lib/secrets/crowdsec-bouncer-key
sudo chown root:root /var/lib/secrets/crowdsec-bouncer-key
```

**3. Restart the bouncer:**

```bash
sudo systemctl restart crowdsec-firewall-bouncer
sudo systemctl status crowdsec-firewall-bouncer
```

The key file at `/var/lib/secrets/crowdsec-bouncer-key` is not managed by Nix
and must be created manually on each new machine. It should never be committed
to git.

## Re-registering the Bouncer

If the bouncer loses its registration (e.g. after a container wipe):

```bash
# Remove the old registration
docker exec crowdsec cscli bouncers delete firewall-bouncer

# Re-add and capture the new key
docker exec crowdsec cscli bouncers add firewall-bouncer

# Update the key file and restart
echo -n "NEW_KEY_HERE" | sudo tee /var/lib/secrets/crowdsec-bouncer-key
sudo systemctl restart crowdsec-firewall-bouncer
```

## Useful Commands

```bash
# View active bouncers
docker exec crowdsec cscli bouncers list

# View active decisions (bans)
docker exec crowdsec cscli decisions list

# View alerts
docker exec crowdsec cscli alerts list

# Install/update a collection
docker exec crowdsec cscli collections install crowdsecurity/sshd

# View installed collections
docker exec crowdsec cscli collections list
```

## Persistent Data

The container mounts the following host paths:

| Host path                        | Container path          | Purpose                  |
|----------------------------------|-------------------------|--------------------------|
| `/var/lib/crowdsec/data`         | `/var/lib/crowdsec/data`| GeoIP DB, decisions, etc |
| `/var/lib/crowdsec/config`       | `/etc/crowdsec`         | Config, hub, bouncers    |
| `/var/log/crowdsec`              | `/var/log/crowdsec`     | CrowdSec logs            |
