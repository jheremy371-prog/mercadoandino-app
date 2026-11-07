#!/bin/bash
set -Eeuo pipefail

PID_FILE="/var/run/mercadoandino-app.pid"

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE")"
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    for _ in {1..10}; do
      kill -0 "$PID" 2>/dev/null || break
      sleep 1
    done
    if kill -0 "$PID" 2>/dev/null; then
      kill -9 "$PID" || true
    fi
  fi
  rm -f "$PID_FILE"
fi

echo "Proceso de Mercado Andino detenido."
