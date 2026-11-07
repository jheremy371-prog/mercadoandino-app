#!/bin/bash
set -Eeuo pipefail

PORT="${PORT:-80}"
URL="http://127.0.0.1:${PORT}/health"

for attempt in {1..15}; do
  if curl --silent --show-error --fail "$URL"; then
    echo
    echo "Validación correcta: Mercado Andino está funcionando."
    exit 0
  fi
  sleep 2
done

echo "ERROR: Mercado Andino no respondió en $URL"
exit 1
