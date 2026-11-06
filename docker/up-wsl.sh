#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose up -d
bash ./sync-wsl-ip.sh
echo
echo "Container iniciado. Aguardando importacao do dump na primeira subida..."
bash ./wait-and-check.sh
