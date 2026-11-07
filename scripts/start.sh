#!/bin/bash
set -Eeuo pipefail

APP_DIR="/home/ec2-user/app"
PID_FILE="/var/run/mercadoandino-app.pid"
LOG_FILE="/var/log/mercadoandino.log"

cd "$APP_DIR"

# Define estos valores en el entorno de la instancia o aquí para tu despliegue.
export AWS_REGION="${AWS_REGION:-us-east-1}"
export BUCKET_NAME="${BUCKET_NAME:-mercadoandino-uploads-llj-4821}"
export PORT="${PORT:-80}"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "La aplicación ya está en ejecución."
  exit 0
fi

nohup node server.js >> "$LOG_FILE" 2>&1 < /dev/null &
echo $! > "$PID_FILE"

sleep 2
if ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "ERROR: No se pudo iniciar Mercado Andino. Revisa $LOG_FILE"
  rm -f "$PID_FILE"
  exit 1
fi

echo "Mercado Andino iniciado. PID: $(cat "$PID_FILE")"
