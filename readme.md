# FredOS NixOS Configuration

Flake-based NixOS configuration for three machines, built and deployed directly from GitHub. No local config management required after initial setup.

## Machines

| Hostname | Description |
|---|---|
| FredOS-Gaming | AMD desktop, UEFI/systemd-boot |
| FredOS-Macbook | Intel laptop, UEFI/systemd-boot |
| FredOS-Mediaserver | Intel server, BIOS/GRUB |

## Structure

```
├── .github
│   └── workflows
│       └── update.yml               # Auto-updates flake.lock daily
├── apps
│   └── zen.nix                      # Zen browser config
├── home-manager
│   ├── fred.nix                     # User-level Home Manager config
│   └── gnome-hm.nix                 # GNOME Home Manager settings
├── hosts
│   ├── FredOS-Gaming.nix            # Gaming: packages, Steam, boot options
│   ├── FredOS-Macbook.nix           # Macbook: packages, power management, boot options
│   ├── FredOS-Mediaserver.nix       # Mediaserver: packages, networking, SSH
│   └── hardware
│       ├── FredOS-Gaming.nix        # AMD GPU, kernel modules, filesystems, bootloader, hostname
│       ├── FredOS-Macbook.nix       # Broadcom WiFi, Intel GPU, Bluetooth, filesystems, bootloader, hostname
│       └── FredOS-Mediaserver.nix   # Intel CPU, data disks, mergerfs pool, GRUB, hostname
├── services
│   ├── arr-interconnect.nix         # Cross-service API key wiring for *arr apps
│   ├── authelia.nix                 # SSO/2FA gateway (protects homepage & camera)
│   ├── bazarr.nix                   # Subtitle management
│   ├── cloudflare-ddns.nix          # Cloudflare dynamic DNS
│   ├── fail2ban.nix                 # Intrusion prevention (SSH, nginx, Authelia, *arr, etc.)
│   ├── game-servers.nix             # Game server definitions
│   ├── go2rtc.nix                   # Camera/RTSP streaming
│   ├── homepage.nix                 # Homepage dashboard with auto-extracted API keys
│   ├── jellyfin.nix                 # Media server
│   ├── nginx.nix                    # Reverse proxy + ACME wildcard cert via Cloudflare DNS-01
│   ├── prowlarr.nix                 # Indexer manager
│   ├── qbittorrent-nox.nix          # Torrent client
│   ├── radarr.nix                   # Movie management
│   ├── server-permissions.nix       # File/dir permission setup
│   └── sonarr.nix                   # TV management
├── settings
│   ├── audio.nix                    # PipeWire / audio config
│   ├── gnome.nix                    # GNOME desktop settings
│   ├── locale.nix                   # Locale, timezone, keyboard
│   ├── shell.nix                    # Fish shell, powerline prompt, fastfetch, nerd fonts
│   └── users.nix                    # User accounts
├── walls                            # Wallpapers
├── common.nix                       # Shared config imported by all hosts
├── flake.lock                       # Auto-generated, updated daily by GitHub Actions
└── flake.nix                        # Flake inputs and host definitions
```

## Day-to-day usage

Edit files directly on GitHub, then on the machine run:

```bash
update
```

That's it. The alias is defined in `common.nix` and expands to:

```bash
sudo nixos-rebuild switch --flake github:ediblerope/nixos-config --refresh --no-write-lock-file
```

Nix automatically matches the running machine's hostname to the correct `nixosConfigurations` entry.

Other useful aliases:

```bash
clean    # sudo nix-collect-garbage -d
```

---

## Adding a new machine

### 1. Fresh NixOS install

Boot the NixOS installer and complete the standard installation.

### 2. Enable flakes temporarily

Add this to `/etc/nixos/configuration.nix` and rebuild:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

```bash
sudo nixos-rebuild switch
```

### 3. Create the hardware config on GitHub

Copy the contents of `/etc/nixos/hardware-configuration.nix` and create `hosts/hardware/FredOS-NEWHOST.nix` on GitHub. Append the hostname and bootloader config to it:

```nix
networking.hostName = "FredOS-NEWHOST";

# For UEFI/systemd-boot machines:
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# For BIOS/GRUB machines instead:
# boot.loader.grub.enable = true;
# boot.loader.grub.devices = [ "/dev/sda" ]; # verify with: sudo grub-probe --target=disk /
```

### 4. Register the host in flake.nix

In `flake.nix` on GitHub, add to `nixosConfigurations`:

```nix
FredOS-NEWHOST = mkHost "FredOS-NEWHOST";
```

### 5. Add host-specific config

Create `hosts/FredOS-NEWHOST.nix` on GitHub for any machine-specific packages or services:

```nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-NEWHOST") {
    # host-specific packages and services here
  };
}
```

Then add it to the imports list in `common.nix`:

```nix
./hosts/FredOS-NEWHOST.nix
```

### 6. Switch to the flake

Run this once on the new machine with the explicit hostname:

```bash
sudo nixos-rebuild switch --flake github:ediblerope/nixos-config#FredOS-NEWHOST --refresh --no-write-lock-file
```

After this succeeds, the plain `update` alias works from then on.

---

## Flake inputs

| Input | Source |
|---|---|
| nixpkgs | `github:NixOS/nixpkgs/nixos-unstable` |
| home-manager | `github:nix-community/home-manager` |
| zen-browser | `github:0xc000022070/zen-browser-flake` |
| nix-cachyos-kernel | `github:xddxdd/nix-cachyos-kernel/release` |

## Mediaserver secrets

Several services on FredOS-Mediaserver require secrets that are stored on the machine (not in the repo). After a fresh deploy, create these before running `update`:

```bash
# Cloudflare API token (used by DDNS and ACME wildcard cert)
# See services/cloudflare-ddns.md for token permissions
echo -n 'your-cloudflare-api-token' | sudo tee /var/secrets/cloudflare-token
sudo chmod 600 /var/secrets/cloudflare-token

# go2rtc RTSP camera URL
echo -n 'rtsp://username:password@camera-ip:554/stream1' | sudo tee /var/secrets/go2rtc-rtsp-url
sudo chmod 600 /var/secrets/go2rtc-rtsp-url

# Authelia secrets — auto-migrated from Docker on first deploy
# If migrating from Docker, ensure these exist at /home/fred/docker/authelia/:
#   - configuration.yml (jwt_secret, session secret, storage key are extracted)
#   - users_database.yml (copied to /var/lib/authelia-main/)
# For a fresh install, create manually:
sudo mkdir -p /var/secrets/authelia
echo -n 'random-jwt-secret'              | sudo tee /var/secrets/authelia/jwt_secret
echo -n 'random-session-secret'          | sudo tee /var/secrets/authelia/session_secret
echo -n 'random-storage-encryption-key'  | sudo tee /var/secrets/authelia/storage_encryption_key
sudo chmod 600 /var/secrets/authelia/*

# Authelia user database (for a fresh install)
# Create users_database.yml with this structure:
#   ---
#   users:
#     username:
#       password: "$argon2id$..."    # hashed — see below
#       displayname: Display Name
#       email: user@example.com
#
# Generate a password hash with:
#   nix-shell -p authelia --run "authelia crypto hash generate argon2"
sudo mkdir -p /var/lib/authelia-main
sudo nano /var/lib/authelia-main/users_database.yml
sudo chown authelia-main:authelia-main /var/lib/authelia-main/users_database.yml
```

## Migrating to a new server

When moving FredOS-Mediaserver to new hardware, back up these state directories from the old server:

```bash
# Service databases and config (stop services first)
/var/lib/jellyfin/          # Library database, users, metadata, API keys
/var/lib/sonarr/            # TV library database, config.xml (API key)
/var/lib/radarr/            # Movie library database, config.xml (API key)
/var/lib/prowlarr/          # Indexer database, config.xml (API key)
/var/lib/bazarr/            # Subtitle database and config
/var/lib/qbittorrent/       # Torrent client config and state
/var/lib/authelia-main/     # User database and session storage

# Secrets
/var/secrets/               # Cloudflare token, go2rtc RTSP URL, Authelia secrets

# Media files
/mnt/storage/               # The mergerfs pool (torrents, media libraries, audiobooks)
```

Steps:

1. Install NixOS on the new server
2. Create `hosts/hardware/FredOS-Mediaserver.nix` from the new `/etc/nixos/hardware-configuration.nix` (new disk UUIDs, bootloader config)
3. Set up the mergerfs pool and mount at `/mnt/storage`
4. Restore `/var/secrets/` (see Mediaserver secrets section above)
5. Run `sudo nixos-rebuild switch --flake github:ediblerope/nixos-config#FredOS-Mediaserver`
6. Stop all services, restore the `/var/lib/` directories listed above, then start services
7. Update Cloudflare DNS if the server's public IP changed

If starting fresh instead of migrating, the services will self-initialize with empty databases. You'll need to redo initial setup in each web UI (add media libraries in Jellyfin, set root folders in Sonarr/Radarr, configure qBittorrent download paths, etc.). The `arr-interconnect` service will auto-wire the connections between them.

## Notes

- `hosts/hardware/` files are committed to the repo — they contain UUIDs and disk layout but no sensitive credentials
- Host-specific behaviour is gated with `lib.mkIf (config.networking.hostName == "...")` or `lib.elem config.networking.hostName [...]`
- GitHub API rate limit (60 req/hour unauthenticated) can occasionally be hit if running `update` many times in quick succession during active config changes — wait ~15 minutes and retry
