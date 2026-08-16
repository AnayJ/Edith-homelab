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

# Find repository location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

EDITH_DIR="/opt/edith"
DATA_DIR="$EDITH_DIR/data"
DOCKER_DIR="$EDITH_DIR/docker"

echo ""
echo "Repository: $REPO_DIR"
echo "Edith directory: $EDITH_DIR"

echo ""
echo "[1/5] Installing prerequisites..."

apt update

apt install -y \
    git \
    curl \
    ca-certificates \
    gnupg

echo ""
echo "[2/5] Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    curl -fsSL https://get.docker.com | sh
fi

systemctl enable docker
systemctl start docker

echo ""
echo "[3/5] Creating Edith directories..."

mkdir -p "$EDITH_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$DOCKER_DIR"

mkdir -p \
    "$DATA_DIR/immich/library" \
    "$DATA_DIR/immich/postgres" \
    "$DATA_DIR/nextcloud" \
    "$DATA_DIR/uptime-kuma" \
    "$DATA_DIR/gitea"

echo ""
echo "[4/5] Creating Docker network..."

if docker network inspect homelab >/dev/null 2>&1; then
    echo "Docker network 'homelab' already exists."
else
    docker network create \
        --driver bridge \
        --subnet 172.20.0.0/16 \
        homelab
fi

echo ""
echo "[5/5] Installing Edith infrastructure..."

echo ""
echo "Base Edith environment is ready."

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
echo "======================================"
echo "       EDITH BASE SETUP COMPLETE"
echo "======================================"
