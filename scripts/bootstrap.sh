#!/bin/bash

set -e

REPO="https://github.com/AnayJ/Edith-homelab.git"
INSTALL_DIR="/opt/edith-homelab"

echo "======================================"
echo "       EDITH BOOTSTRAP INSTALLER"
echo "======================================"

if [ "$EUID" -ne 0 ]; then
    echo "Run with:"
    echo "sudo ./bootstrap.sh"
    exit 1
fi

echo ""
echo "[1/3] Installing Git..."

apt update
apt install -y git

echo ""
echo "[2/3] Cloning Edith repository..."

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Edith repository already exists."
else
    git clone "$REPO" "$INSTALL_DIR"
fi

echo ""
echo "[3/3] Starting Edith installer..."

cd "$INSTALL_DIR"

chmod +x scripts/install.sh

exec ./scripts/install.sh
