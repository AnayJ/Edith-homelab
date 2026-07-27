Edith Homelab

> Infrastructure as Code for Edith.

## Philosophy

Edith is a self-hosted homelab built using Docker.
The goal is that a completely fresh Ubuntu-server installation can become Edith by running a single installer.

## Current Services

- Homepage
- Portainer
- Uptime Kuma
- Nextcloud
- Immich
- Gitea
- Jarvis
- Glances
- PostgreSQL

## Future

- One-command installation
- Automatic backups
- Automatic restoration
- Jarvis-assisted deployment

## Repo structure

edith-homelab/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── docker/
│   ├── homepage/
│   ├── immich/
│   ├── jarvis/
│   ├── nextcloud/
│   ├── gitea/
│   ├── portainer/
│   ├── uptime-kuma/
│   └── glances/
│
├── docs/
│
├── scripts/
│
└── backups/
    └── .gitkeep