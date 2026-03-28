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
flake.nix                        # Flake inputs and host definitions
common.nix                       # Shared config for all hosts
hosts/
  FredOS-Gaming.nix              # Gaming-specific config
  FredOS-Macbook.nix             # Macbook-specific config
  FredOS-Mediaserver.nix         # Mediaserver-specific config
  hardware/
    FredOS-Gaming.nix            # Hardware config + bootloader
    FredOS-Macbook.nix
    FredOS-Mediaserver.nix
apps/                            # Per-app config files
settings/                        # Shared system settings (GNOME, locale, audio, etc.)
services/                        # Service definitions
home-manager/                    # Home Manager config
walls/                           # Wallpapers
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

Boot the NixOS installer and complete the standard installation. Note the `system.stateVersion` it generates — you'll need it later.

### 2. Enable flakes temporarily

Add this to `/etc/nixos/configuration.nix` and rebuild:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

```bash
sudo nixos-rebuild switch
```

### 3. Create the hardware config on GitHub

Copy the contents of `/etc/nixos/hardware-configuration.nix` and create `hosts/hardware/FredOS-NEWHOST.nix` on GitHub. Append the following to it:

```nix
networking.hostName = "FredOS-NEWHOST";

# Match what the installer configured — systemd-boot for UEFI:
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.systemd-boot.configurationLimit = 5;
boot.initrd.systemd.enable = true;

# For BIOS/GRUB machines instead:
# boot.loader.grub.enable = true;
# boot.loader.grub.devices = [ "/dev/sda" ]; # verify with: sudo grub-probe --target=disk /

nix.settings.experimental-features = [ "nix-command" "flakes" ];
system.stateVersion = "25.11"; # use the version the installer generated
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
    # host-specific config here
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
| omnisearch | `git+https://git.bwaaa.monster/omnisearch` |
| zen-browser | `github:0xc000022070/zen-browser-flake` |
| nix-flatpak | `github:gmodena/nix-flatpak` |

## Notes

- `hosts/hardware/` files are committed to the repo — they contain UUIDs and disk layout but no sensitive credentials
- Host-specific behaviour is gated with `lib.mkIf (config.networking.hostName == "...")` or `lib.elem config.networking.hostName [...]`
- GitHub API rate limit (60 req/hour unauthenticated) can occasionally be hit if running `update` many times in quick succession during active config changes — wait ~15 minutes and retry
