# Kaimon Edge Deploy

Docker Compose deployment for [kaimon-edge](https://hub.docker.com/r/polylvst/kaimon-edge) (backend) and [kaimon-edge-fe](https://hub.docker.com/r/polylvst/kaimon-edge-fe) (frontend).

## Quick Start

```bash
cp .env.example .env
# Edit .env as needed
docker compose up -d
```

Frontend will be available at `http://localhost:3000`.

## Configuration

See `.env.example` for available environment variables:

| Variable | Default | Description |
|---|---|---|
| `EDGE_DEVICE_ID` | `edge-1` | Unique identifier for this edge device |
| `MAIN_HUB_URL` | _(empty)_ | URL of the main Shinkaimon Hub for syncing |
| `SYNC_INTERVAL_SECONDS` | `30` | Interval for syncing with the hub e.g. upload attendance |
| `HUB_SYNC_INTERVAL_SECONDS` | `30` | Interval for hub-side sync e.g. pulling users |

## Data

Persistent data is stored in `./data/`:

- `data/db/` — SQLite database
- `data/.deepface/` — Face recognition model cache
