#!/bin/bash

set -e

echo "======================================"
echo "        EDITH HOMELAB INSTALLER"
echo "======================================"

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run:"
    echo "sudo ./scripts/install.sh"
    exit 1
fi

# Locate this repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

EDITH_DIR="/opt/edith"
DATA_DIR="$EDITH_DIR/data"

SERVICES=(
    "battery-api"
    "homepage"
    "immich"
    "nextcloud"
    "portainer"
    "uptime-kuma"
    "gitea"
    "glances"
)

echo ""
echo "Repository: $REPO_DIR"
echo "Data directory: $DATA_DIR"

# --------------------------------------
# 1. Prerequisites
# --------------------------------------

echo ""
echo "[1/6] Installing prerequisites..."

apt update

apt install -y \
    git \
    curl \
    ca-certificates \
    gnupg

# --------------------------------------
# 2. Docker
# --------------------------------------

echo ""
echo "[2/6] Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    curl -fsSL https://get.docker.com | sh
fi

systemctl enable docker
systemctl start docker

# --------------------------------------
# 3. Edith directories
# --------------------------------------

echo ""
echo "[3/6] Creating Edith data directories..."

mkdir -p \
    "$DATA_DIR/immich/library" \
    "$DATA_DIR/immich/postgres" \
    "$DATA_DIR/nextcloud" \
    "$DATA_DIR/uptime-kuma" \
    "$DATA_DIR/gitea"

# --------------------------------------
# 4. Docker network
# --------------------------------------

echo ""
echo "[4/6] Configuring Docker network..."

if docker network inspect homelab >/dev/null 2>&1; then
    echo "Docker network 'homelab' already exists."
else
    docker network create \
        --driver bridge \
        --subnet 172.20.0.0/16 \
        homelab
fi

# --------------------------------------
# 5. Immich configuration
# --------------------------------------

echo ""
echo "[5/6] Configuring Immich..."

IMMICH_DIR="$REPO_DIR/docker/immich"
IMMICH_ENV="$IMMICH_DIR/.env"

if [ -f "$IMMICH_ENV" ]; then
    echo "Immich .env already exists."
else
    read -rsp "Enter Immich PostgreSQL password: " DB_PASSWORD
    echo ""

    if [ -z "$DB_PASSWORD" ]; then
        echo "ERROR: Password cannot be empty."
        exit 1
    fi

    cat > "$IMMICH_ENV" <<EOF
UPLOAD_LOCATION=/opt/edith/data/immich/library
DB_DATA_LOCATION=/opt/edith/data/immich/postgres
TZ=Asia/Kolkata
IMMICH_VERSION=v3
DB_PASSWORD=$DB_PASSWORD
DB_USERNAME=postgres
DB_DATABASE_NAME=immich
EOF

    chmod 600 "$IMMICH_ENV"

    echo "Immich configuration created."
fi

# --------------------------------------
# 6. Deploy services
# --------------------------------------

echo ""
echo "[6/6] Deploying Edith services..."

# Preflight check
for SERVICE in "${SERVICES[@]}"; do
    SERVICE_DIR="$REPO_DIR/docker/$SERVICE"

    if [ ! -f "$SERVICE_DIR/docker-compose.yml" ]; then
        echo "ERROR: Missing Compose file for $SERVICE"
        echo "Expected:"
        echo "$SERVICE_DIR/docker-compose.yml"
        exit 1
    fi
done

echo "All Compose files found."

for SERVICE in "${SERVICES[@]}"; do
    SERVICE_DIR="$REPO_DIR/docker/$SERVICE"

    echo ""
    echo "--------------------------------------"
    echo "Deploying: $SERVICE"
    echo "--------------------------------------"

    docker compose \
        -f "$SERVICE_DIR/docker-compose.yml" \
        up -d --build

    echo "$SERVICE deployed."
done

# --------------------------------------
# Verification
# --------------------------------------

echo ""
echo "======================================"
echo "       EDITH INSTALLATION COMPLETE"
echo "======================================"

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker Compose:"
docker compose version

echo ""
echo "Docker network:"
docker network inspect homelab \
    --format 'Name: {{.Name}} | Driver: {{.Driver}} | Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}'

echo ""
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "Edith is ready."
