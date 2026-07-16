# nix

Modular NixOS flake for the Oversoul workspace environment.

## Deploy

1. Copy this repository to `/etc/nixos`
2. Build and switch:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#my-system
```

## Layout

- `configuration.nix` + `modules/` for NixOS system modules
- `home/` for user-level Oversoul and shell setup
- `scripts/` health/debug/cleanup/status utilities
- `templates/` starter templates for mode and dev shells
