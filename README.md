# nix
/etc/nixos/
├── flake.nix
├── configuration.nix
├── hardware-configuration.nix
├── modules/
│   ├── system.nix
│   ├── networking.nix
│   ├── packages.nix
│   ├── desktop.nix
│   ├── services.nix
│   ├── users.nix
│   ├── modes/
│   │   ├── mode-switch.nix
│   │   ├── vibing.nix
│   │   ├── schooling.nix
│   │   ├── building.nix
│   │   ├── creating.nix
│   │   └── spiraling.nix
│   └── oversoul.nix
├── home/
│   ├── oversoul.nix
│   ├── shell.nix
│   ├── aliases.nix
│   └── scripts/
│       ├── health-check.sh
│       ├── clean-up.sh
│       ├── debug-tools.sh
│       ├── status.sh
│       ├── mode-switch.sh
│       ├── ai-control.sh
│       └── network-status.sh
└── templates/
    ├── devenv-shell.nix
    ├── flake-template.nix
    └── mode-template.nix
