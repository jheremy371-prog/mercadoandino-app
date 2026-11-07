#!/bin/bash
set -Eeuo pipefail

APP_DIR="/home/ec2-user/app"
cd "$APP_DIR"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: Node.js y npm deben estar instalados en la instancia EC2."
  exit 1
fi

if [ -f package-lock.json ]; then
  npm ci --omit=dev
else
  npm install --omit=dev
fi

chown -R ec2-user:ec2-user "$APP_DIR"
echo "Dependencias instaladas correctamente."
