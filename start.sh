#!/usr/bin/env bash
set -euo pipefail

# Start the Docker Compose stack and launch Chrome in kiosk mode

FRONTEND_URL="http://localhost:3000"
TIMEOUT=60

# --- Wait for network ---
echo "Waiting for network..."
for i in $(seq 1 15); do
    ping -c1 -W2 8.8.8.8 &>/dev/null && break
    sleep 2
done

# --- Start services ---
echo "Pulling latest images..."
docker compose pull || echo "WARNING: Pull failed (offline?), using local images."

echo "Starting Docker Compose stack..."
docker compose up -d

# --- Wait for frontend ---
echo "Waiting for frontend at $FRONTEND_URL ..."
elapsed=0
until curl -s -o /dev/null -w '%{http_code}' "$FRONTEND_URL" | grep -q 200; do
    if [ "$elapsed" -ge "$TIMEOUT" ]; then
        echo "ERROR: Frontend did not become ready within ${TIMEOUT}s"
        exit 1
    fi
    sleep 2
    elapsed=$((elapsed + 2))
    echo "  Still waiting... (${elapsed}s)"
done
echo "Frontend is ready."

# --- Detect Chrome/Chromium ---
CHROME=""
for candidate in chromium-browser chromium google-chrome; do
    if command -v "$candidate" &>/dev/null; then
        CHROME="$candidate"
        break
    fi
done

if [ -z "$CHROME" ]; then
    echo "ERROR: No Chrome or Chromium browser found."
    exit 1
fi

echo "Launching $CHROME in kiosk mode..."
exec "$CHROME" \
    --kiosk \
    --noerrdialogs \
    --disable-infobars \
    --no-first-run \
    --disable-translate \
    --disable-features=TranslateUI \
    --check-for-update-interval=31536000 \
    --autoplay-policy=no-user-gesture-required \
    "$FRONTEND_URL"
