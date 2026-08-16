# Edith Homelab

Edith is a personal, self-hosted homelab running on **Ubuntu Server** and **Docker**.

The primary goal of this repository is to make the Edith infrastructure fully reproducible, portable, and easy to rebuild on any machine.

---

##  Architecture

```text
Ubuntu Server
│
├── Docker
│   │
│   └── homelab network (bridge: 172.20.0.0/16)
│       │
│       ├── Homepage
│       ├── Immich
│       ├── Nextcloud
│       ├── Portainer
│       ├── Uptime Kuma
│       ├── Gitea
│       ├── Glances
│       └── Battery API
│
├── /opt/edith/data/
│   ├── immich/
│   ├── nextcloud/
│   ├── uptime-kuma/
│   └── gitea/
│
└── Ollama (Native host / container)
```

### Services Overview

| Service | Purpose |
| :--- | :--- |
| **[Homepage](https://gethomepage.dev/)** | Unified homelab dashboard |
| **[Immich](https://immich.app/)** | Self-hosted photo and video backup |
| **[Nextcloud](https://nextcloud.com/)** | Personal cloud storage and file sync |
| **[Portainer](https://www.portainer.io/)** | Container management web UI |
| **[Uptime Kuma](https://github.com/louislam/uptime-kuma)** | Service health monitoring & alerting |
| **[Gitea](https://about.gitea.com/)** | Lightweight, self-hosted Git service |
| **[Glances](https://nicolargo.github.io/glances/)** | Real-time system monitoring |
| **Battery API** | Custom API for Edith host battery metrics |



---

##  Repository Structure

```text
Edith-homelab/
│
├── docker/
│   ├── battery-api/
│   ├── gitea/
│   ├── glances/
│   ├── homepage/
│   ├── immich/
│   ├── nextcloud/
│   ├── portainer/
│   └── uptime-kuma/
│
├── scripts/
│   ├── bootstrap.sh
│   └── install.sh
│
└── README.md
```

---

##  Prerequisites & Requirements

- **OS:** Ubuntu Server (x86_64)
- **Connectivity:** Active internet connection
- **Hardware:** Adequate RAM and disk storage for media/databases
- **Software Dependencies:**
  - Docker Engine
  - Docker Compose plugin

> *Note:* The included setup script (`install.sh`) can automatically install and configure Docker and Compose if they are not detected.

---

##  Docker Networking

All services communicate across an external bridge network:

| Attribute | Configuration |
| :--- | :--- |
| **Network Name** | `homelab` |
| **Driver** | `bridge` |
| **Subnet** | `172.20.0.0/16` |
| **Gateway** | `172.20.0.1` |

*The installation script creates this network automatically before starting container stacks.*

---

##  Installation

### Option 1: Standard Install (Recommended)

Clone the repository and run the installer:

```bash
git clone https://github.com/AnayJ/Edith-homelab.git
cd Edith-homelab
sudo ./scripts/install.sh
```

### Option 2: Bootstrap Quickstart

Use the standalone bootstrap script to fetch dependencies and trigger the full installer in one step:

```bash
sudo ./scripts/bootstrap.sh
```

---

##  Storage & Data Management

### Persistent Data Structure

Application databases, media libraries, and uploads live outside the Git repository in `/opt/edith/data/`:

```text
/opt/edith/data/
├── gitea/
├── immich/
│   ├── library/
│   └── postgres/
├── nextcloud/
└── uptime-kuma/
```

>  **Important:** Never commit `/opt/edith/data/` or database dumps to Git.

### Secrets & Environment Variables

All sensitive values (passwords, tokens, API keys) are excluded via `.gitignore`. Copy `.env.example` templates to `.env` before starting services:

```bash
cp docker/immich/.env.example docker/immich/.env
# Edit secrets accordingly
nano docker/immich/.env
```

##  Operations & Maintenance

### Updating Individual Services

Navigate to the target service directory to pull upstream images and recreate containers:

```bash
cd docker/uptime-kuma
docker compose pull
docker compose up -d
```

For locally built containers (e.g., `battery-api`):

```bash
docker compose up -d --build
```

---

##  Backup & Disaster Recovery

### Backup Scope

| Tier | Handled By | Contents |
| :--- | :--- | :--- |
| **Infrastructure** | Git Repository | Compose files, config templates, bootstrap scripts |
| **Persistent Data** | Dedicated Backups | Immich photos & Postgres DB, Nextcloud files, Gitea repos, Portainer volumes |

### Disaster Recovery Flow

```text
[ Fresh Ubuntu Server ]
          │
          ▼
  [ Run bootstrap.sh ]
          │
          ▼
 [ Clone Edith-homelab ]
          │
          ▼
   [ Run install.sh ]
          │
          ▼
[ Docker + Network + Stacks Initialized ]
          │
          ▼
[ Restore Backups to /opt/edith/data ]
          │
          ▼
    [ Edith Restored ]
```

---

##  Design Principles

- **Reproducible:** Zero manual configuration drifts; buildable from scripts.
- **Documented:** Clear layout of services, networking, and data paths.
- **Portability:** Decoupled infrastructure config from persistent storage.
- **Segregation:** Strict boundary between code, secrets, and application data.
