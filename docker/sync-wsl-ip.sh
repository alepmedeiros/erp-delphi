#!/usr/bin/env bash
# Ajusta HostName no Cadastros para o Delphi (Windows) enxergar o MariaDB no WSL.
set -euo pipefail
cd "$(dirname "$0")"

CONN_FILE="/mnt/c/repositorio/Exemplos_ERP-PDV/T2TiERP-2-Delphi/Retaguarda/Cliente/Cadastros/MySQL_DBExpress_conn.txt"
MODE="${1:-auto}"

if [ ! -f "$CONN_FILE" ]; then
  echo "Arquivo nao encontrado: $CONN_FILE"
  exit 1
fi

if [ "$MODE" = "localhost" ]; then
  HOST="127.0.0.1"
elif [ "$MODE" = "wsl-ip" ]; then
  HOST=$(hostname -I | awk '{print $1}')
else
  if grep -qi 'networkingMode=mirrored' /mnt/c/Windows/System32/config/systemprofile/.wslconfig 2>/dev/null \
     || grep -qi 'networkingMode=mirrored' /mnt/c/Users/*/.wslconfig 2>/dev/null; then
    HOST="127.0.0.1"
  else
    HOST=$(hostname -I | awk '{print $1}')
    echo "Dica: com networkingMode=mirrored no .wslconfig, use: bash sync-wsl-ip.sh localhost"
  fi
fi

sed -i "s/^HostName=.*/HostName=${HOST}/" "$CONN_FILE"

echo "HostName=${HOST}"
echo "Arquivo: Retaguarda/Cliente/Cadastros/MySQL_DBExpress_conn.txt"
