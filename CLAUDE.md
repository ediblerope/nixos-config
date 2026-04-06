# FredOS NixOS Configuration

This is a NixOS flake-based configuration for multiple hosts:
- **FredOS-Gaming** — gaming desktop
- **FredOS-Mediaserver** — home media server
- **FredOS-Macbook** — MacBook laptop

## Structure

- `flake.nix` — flake inputs/outputs; all hosts use `nixpkgs` unstable
- `common.nix` — shared configuration across all hosts
- `hosts/` — per-host NixOS configuration modules
- `hosts/hardware/` — hardware-specific configuration
- `home-manager/` — Home Manager configuration (via NixOS module)
- `services/` — modular service definitions imported by hosts
- `settings/` — shared settings/variables

## Code Evaluation

Always validate Nix expressions with `nix eval` before committing. For example:

```bash
# Evaluate a specific attribute to check for syntax/type errors
nix eval .#nixosConfigurations.FredOS-Gaming.config.system.stateVersion

# Evaluate the full flake outputs to catch top-level errors
nix eval .#nixosConfigurations --apply builtins.attrNames
```

Use `nix flake check` for a broader check of the flake.
