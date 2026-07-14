# redeploy.sh  —  one-stop container (re)deployer
# Bash ≥4 required for associative arrays.
# Source this file in ~/.bashrc or ~/.zshrc to get the `redeploy` command.
# Update the path below to match where kalpataru-grove is cloned on this machine.
#   source /path/to/kalpataru-grove/scripts/redeploy.sh

redeploy() {

########################################
# 1. CLI parsing
########################################
local APP="${1:-}"
local VER="${2:-}"
local RAW_SUFFIX="${3:-}"          # "" | --stg | -stg | -stg-custom | --redirect

# Allow: redeploy <app> --redirect  OR  redeploy <app> redirect  (no explicit version either way)
if [[ ( "$VER" == "--redirect" || "$VER" == "redirect" ) && -z "$RAW_SUFFIX" ]]; then
  RAW_SUFFIX="--redirect"
  VER="redirect"
fi

if [[ -z "$APP" || -z "$VER" ]]; then
  echo "Usage: redeploy <app_name> <version> [--stg | -stg | --dev | -dev | -xxx | --redirect]" >&2
  echo "       redeploy <app_name> --redirect   (or: redeploy <app_name> redirect)" >&2
  return 64
fi

local SUFFIX
case "$RAW_SUFFIX" in
  ""          ) SUFFIX="";;
  --stg       ) SUFFIX="-stg";;
  --dev       ) SUFFIX="-dev";;
  --redirect  ) SUFFIX="-redirect";;
  -*          ) SUFFIX="$RAW_SUFFIX";;
  *           ) echo "Bad suffix $RAW_SUFFIX  (must start with '-')" >&2; return 64;;
esac

local CONTAINER="${APP}${SUFFIX}"

# Guard against accidentally running a -dev#/-rc# tagged image as prod
if [[ -z "$SUFFIX" && "$VER" =~ -(dev|rc)[0-9]*$ ]]; then
  local CONFIRM
  read -r -p "⚠️  '${VER}' looks like a non-prod build, but no --stg/--dev flag was given — deploy as PROD anyway? [y/N] " CONFIRM
  case "$CONFIRM" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted." >&2; return 1;;
  esac
fi

########################################
# 2. Port lookup
########################################
declare -A PORT_MAP=(
  [skrutable]=5010        [skrutable-stg]=5011
                          [skrutable-redirect]=5011
                          [skrutable-dev]=5012
  [splitter-server]=5020
  [vatayana]=5030         [vatayana-stg]=5031
                          [vatayana-redirect]=5031
                          [vatayana-dev]=5032
  [panditya]=5040         [panditya-stg]=5041
                          [panditya-redirect]=5041
                          [panditya-dev]=5042
  [hansel]=5050           [hansel-stg]=5051
                          [hansel-redirect]=5051
                          [hansel-dev]=5052
  [kalpataru-grove]=5060  [kalpataru-grove-stg]=5061
                          [kalpataru-grove-dev]=5062
  [firewatch]=5070        [firewatch-stg]=5071
                          [firewatch-dev]=5072
)

local PORT="${PORT_MAP[$CONTAINER]:-}"
if [[ -z "$PORT" ]]; then
  echo "Unknown app / stage combo: $CONTAINER" >&2
  return 65
fi

########################################
# 3. Image name & per-app run flags
########################################
local IMAGE="tylergneill/${APP}-app"
local RUN_OPTS=(--restart unless-stopped)

# Redirect and stg share a port, so only one may run at a time.
if [[ "$SUFFIX" == "-redirect" ]]; then
  echo "➤ Stopping/removing stg container if present"
  docker stop  "${APP}-stg" 2>/dev/null || true
  docker rm    "${APP}-stg" 2>/dev/null || true
  # redirect image is self-contained — no extra RUN_OPTS needed
elif [[ "$SUFFIX" == "-stg" ]]; then
  echo "➤ Stopping/removing redirect container if present"
  docker stop  "${APP}-redirect" 2>/dev/null || true
  docker rm    "${APP}-redirect" 2>/dev/null || true
fi

if [[ "$SUFFIX" != "-redirect" ]]; then
  case "$APP" in
    skrutable)
        RUN_OPTS+=(
          -v /home/tyler/cred/gcp_uploader.json:/app/assets/uploader.json:ro
          -e GOOGLE_APPLICATION_CREDENTIALS=/app/assets/uploader.json
        )
        [[ "$SUFFIX" == "-dev" ]] && RUN_OPTS+=(-e SKRUTABLE_DEBUG_TIMING=1)
        ;;
    vatayana)
        local TS_KEYS_FILE="/home/tyler/turnstile_keys/vatayana${SUFFIX}"
        local TS_SITE_KEY
        local TS_SECRET_KEY
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
fi

########################################
# 4. Pull, stop, remove, run
########################################
echo "➤ Pulling ${IMAGE}:${VER}"
docker pull "${IMAGE}:${VER}"

echo "➤ Stopping/removing old container (ignore 'No such …' warnings)"
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

}
