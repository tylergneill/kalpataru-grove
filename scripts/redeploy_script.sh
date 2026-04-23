#!/usr/bin/env bash
# redeploy.sh  —  one-stop container (re)deployer
# Bash ≥4 required for associative arrays.

set -euo pipefail

########################################
# 1. CLI parsing
########################################
APP="${1:-}"
VER="${2:-}"
RAW_SUFFIX="${3:-}"          # "" | --stg | -stg | -stg-custom

if [[ -z "$APP" || -z "$VER" ]]; then
  echo "Usage: $0 <app_name> <version> [--stg | -stg | -stg-xxx]" >&2
  exit 64
fi

case "$RAW_SUFFIX" in
  ""    ) SUFFIX="";;
  --stg ) SUFFIX="-stg";;
  -*    ) SUFFIX="$RAW_SUFFIX";;
  *     ) echo "Bad suffix $RAW_SUFFIX  (must start with ‘-’)" >&2; exit 64;;
esac

CONTAINER="${APP}${SUFFIX}"

########################################
# 2. Port lookup
########################################
declare -A PORT_MAP=(
  [skrutable]=5010              [skrutable-stg]=5012
  [skrutable-stg-1-7-dominik]=5011
  [vatayana]=5020               [vatayana-stg]=5021
  [hansel]=5030                 [hansel-stg]=5031
  [brucheion-nbhu]=5040
  [splitter-server]=5060
  [firewatch]=5070              [firewatch-stg]=5071
  [kalpataru-grove]=5080        [kalpataru-grove-stg]=5081
  [panditya]=5090               [panditya-stg]=5091
)

PORT="${PORT_MAP[$CONTAINER]:-}"
if [[ -z "$PORT" ]]; then
  echo "Unknown app / stage combo: $CONTAINER" >&2
  exit 65
fi

########################################
# 3. Image name & per-app run flags
########################################
IMAGE="tylergneill/${APP}-app"     # default
RUN_OPTS=(--restart unless-stopped)

case "$APP" in
  skrutable)
      RUN_OPTS+=(
        -v /home/tyler/cred/gcp_uploader.json:/app/assets/uploader.json:ro
        -e GOOGLE_APPLICATION_CREDENTIALS=/app/assets/uploader.json
      )
      ;;
  vatayana)
      TS_KEYS_FILE="/home/tyler/turnstile_keys/vatayana${SUFFIX}"
      TS_SITE_KEY=$(sed -n '1p' "$TS_KEYS_FILE")
      TS_SECRET_KEY=$(sed -n '2p' "$TS_KEYS_FILE")
      RUN_OPTS+=(--network sktnet -e DB_SERVER=mongo
        -e TURNSTILE_SITE_KEY="$TS_SITE_KEY"
        -e TURNSTILE_SECRET_KEY="$TS_SECRET_KEY")
      ;;
  panditya)
      RUN_OPTS+=(
        -v /home/tyler/video:/app/static/video:ro
      )
      ;;
  hansel)
      RUN_OPTS+=(-v "/home/tyler/hansel-data${SUFFIX}:/app/static/data")
      ;;
  firewatch)
      RUN_OPTS+=(
        -v /var/log/nginx:/app/static/data
        -v "/home/tyler/firewatch-data-cache${SUFFIX}:/app/static/cache"
        -v /home/tyler/firewatch-data-geoip-db:/data/geoip
        -e GEOIP_DATABASE_PATH=/data/geoip/GeoLite2-City.mmdb
      )
      ;;
esac

########################################
# 4. Pull, stop, remove, run
########################################
echo "➤ Pulling ${IMAGE}:${VER}"
docker pull "${IMAGE}:${VER}"

echo "➤ Stopping/removing old container (ignore ‘No such …’ warnings)"
docker stop  "$CONTAINER" 2>/dev/null || true
docker rm    "$CONTAINER" 2>/dev/null || true

echo "➤ Final docker run command:"
echo docker run --name "$CONTAINER" -d \
     -p "${PORT}:${PORT}" \
     "${RUN_OPTS[@]}" \
     "${IMAGE}:${VER}"

echo "➤ Running ${CONTAINER} on port ${PORT}"
docker run --name "$CONTAINER" -d \
          -p "${PORT}:${PORT}" \
          "${RUN_OPTS[@]}" \
          "${IMAGE}:${VER}"

echo "✓  Deployed ${CONTAINER}.  Tailing logs …"
sleep 1
docker logs -f "$CONTAINER"
