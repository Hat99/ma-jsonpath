#!/bin/bash
set -euo pipefail

# Konfiguration
CONTAINER_NAME="ydb"
DATA_DIR="$(pwd)/build/ydb-data"
IMAGE="download.yottadb.com/yottadb/yottadb"

# Datenverzeichnis anlegen
mkdir -p "$DATA_DIR"

# Vorherigen Container löschen (falls vorhanden)
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Interaktiven Container starten
docker run --name "$CONTAINER_NAME" --rm -it \
  -p 9080:9080 \
  -v "$DATA_DIR:/data" \
  "$IMAGE" bash
