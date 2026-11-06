#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for i in $(seq 1 60); do
  st=$(docker inspect -f '{{.State.Health.Status}}' t2tierp-mariadb 2>/dev/null || echo unknown)
  echo "[$i] health=$st"
  if [ "$st" = "healthy" ]; then
    break
  fi
  sleep 5
done

docker exec t2tierp-mariadb mariadb -uroot -proot -e "
SHOW DATABASES;
SELECT COUNT(*) AS tabelas FROM information_schema.tables WHERE table_schema='t2tierp';
SELECT LOGIN, ADMINISTRADOR FROM t2tierp.usuario;
"
