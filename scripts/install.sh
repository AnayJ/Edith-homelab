#!/bin/bash

set -e

echo "======================================"
echo "        Edith Homelab Installer"
echo "======================================"

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root:"
    echo "sudo ./scripts/install.sh"
    exit 1
fi

echo ""
echo "[1/5] Updating system..."
apt update
apt upgrade -y

echo ""
echo "[2/5] Installing required packages..."
apt install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release

echo ""
echo "[3/5] Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    curl -fsSL https://get.docker.com | sh
fi

echo ""
echo "[4/5] Enabling Docker..."

systemctl enable docker
systemctl start docker

echo ""
echo "[5/5] Creating Edith Docker network..."

if docker network inspect homelab >/dev/null 2>&1; then
    echo "Docker network 'homelab' already exists."
else
    docker network create \
        --driver bridge \
        --subnet 172.20.0.0/16 \
        homelab
fi

echo ""
echo "======================================"
echo "       Edith base setup complete!"
echo "======================================"
echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker network:"
docker network inspect homelab \
    --format 'Name: {{.Name}} | Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}'

echo ""
echo "Next phase will deploy Edith services."
