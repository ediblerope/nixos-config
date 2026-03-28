# FredOS NixOS Configuration

Multi-host NixOS configuration managed via flakes, built and deployed directly from GitHub. No local config management required — all changes are made via the GitHub web editor.

## How it works

All machines pull their configuration directly from this repo at build time:

```bash
sudo nixos-rebuild switch --flake github:ediblerope/nixos-config --refresh --no-write-lock-file
```

This is aliased to `update` on all machines.

## Repo structure

```
flake.nix                        # Flake inputs and host definitions
common.nix                       # Shared config imported by all hosts
hosts/
  FredOS-Gaming.nix              # Gaming PC specific config
  FredOS-Macbook.nix             # Macbook specific config
  FredOS-Mediaserver.nix         # Mediaserver specific config
  hardware/
    FredOS-Gaming.nix            # Hardware config + bootloader + hostname
    FredOS-Macbook.nix
    FredOS-Mediaserver.nix
apps/                            # Per-app config files
settings/                        # System settings (GNOME, locale, audio, etc.)
services/                        # System services (Jellyfin, Sonarr, nginx, etc.)
home-manager/                    # Home Manager config
walls/                           # Wallpapers
```

## Flake inputs

| Input | Source |
|---|---|
| nixpkgs | github:NixOS/nixpkgs/nixos-unstable |
| home-manager | github:nix-community/home-manager |
| omnisearch | git+https://git.bwaaa.monster/omnisearch |
| zen-browser | github:0xc000022070/zen-browser-flake |
| nix-flatpak | github:gmodena/nix-flatpak |

## Day-to-day usage

| Task | Command |
|---|---|
| Update system | `update` |
| Garbage collect | `clean` |
| First-run on new machine | See below |

---

## Adding a new machine

### 1. Fresh NixOS install

Boot the NixOS installer and complete the standard installation. Note the `system.stateVersion` the installer sets — you'll need it later.

### 2. Enable flakes

After the base install, add this to `/etc/nixos/configuration.nix` and run `sudo nixos-rebuild switch`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### 3. Create the hardware config on GitHub

Copy the contents of `/etc/nixos/hardware-configuration.nix` and create `hosts/hardware/FredOS-NEWHOST.nix` in this repo via the GitHub web editor. Append the following to it:

```nix
networking.hostName = "FredOS-NEWHOST";

# Match whatever bootloader the installer set up:
boot.loader.systemd-boot.enable = true;       # UEFI systems
boot.loader.efi.canTouchEfiVariables = true;  # UEFI systems
# boot.loader.grub.enable = true;             # BIOS systems
# boot.loader.grub.devices = [ "/dev/sda" ];  # BIOS systems — verify with: sudo grub-probe --target=disk /

boot.loader.systemd-boot.configurationLimit = 5;  # UEFI only
boot.initrd.systemd.enable = true;                # UEFI only

nix.settings.experimental-features = [ "nix-command" "flakes" ];

system.stateVersion = "25.11";  # Use the version the installer generated
```

### 4. Add the host to flake.nix

In `flake.nix`, add the new host to `nixosConfigurations`:

```nix
FredOS-NEWHOST = mkHost "FredOS-NEWHOST";
```

### 5. Create a host-specific config file

Create `hosts/FredOS-NEWHOST.nix` for any machine-specific packages or services. Wrap everything in a hostname guard:

```nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-NEWHOST") {
    environment.systemPackages = with pkgs; [
      # host-specific packages
    ];
  };
}
```

Then add it to the imports list in `common.nix`:

```nix
./hosts/FredOS-NEWHOST.nix
```

### 6. Switch to the flake

Run this on the new machine (first time only — requires explicit hostname):

```bash
sudo nixos-rebuild switch --flake github:ediblerope/nixos-config#FredOS-NEWHOST --refresh --no-write-lock-file
```

After this succeeds, the `update` alias works normally from that point on.

---

## Notes

- **GitHub rate limiting** — `--refresh` queries the GitHub API on every run. At 60 unauthenticated requests/hour this is fine for normal use but will hit the limit during rapid iteration. Wait ~15 minutes if you see a 403 rate limit error.
- **hardware-configuration.nix** — do not run `nixos-generate-config` and expect to copy the output directly. Always append the hostname, bootloader, stateVersion and flake settings as shown above.
- **system.autoUpgrade** — disabled on all hosts. Updates are done manually via the `update` alias.