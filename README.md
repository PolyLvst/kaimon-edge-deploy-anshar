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
| `IDLE_VIDEO_ENABLED` | `false` | Play a fullscreen YouTube video while no face is detected |
| `IDLE_VIDEO_URL` | _(empty)_ | Video, playlist or channel link to play |
| `IDLE_VIDEO_DELAY_SECONDS` | `30` | Seconds without a face before the video takes over |
| `IDLE_VIDEO_MUTED` | `true` | Start playback muted |

## Idle Attract Video

While nobody is standing in front of the camera the kiosk can play a YouTube video
fullscreen. Face detection keeps running behind the overlay, so the video disappears
the instant someone walks up and the normal verification UI returns.

`IDLE_VIDEO_URL` accepts any of:

| Link | Behaviour |
|---|---|
| `https://youtu.be/abc123XYZ_0` | Single video, looped |
| `https://www.youtube.com/playlist?list=PL...` | Playlist, in playlist order |
| `https://www.youtube.com/channel/UC...` | Every video on the channel, **newest first** |
| `https://www.youtube.com/@SomeChannel` | Same, but the channel id is looked up at container start — needs internet at that moment |

Handle links (`@name`) are resolved once during startup and logged; if the lookup
fails (device offline), use the `/channel/UC...` form of the link instead, which
needs no lookup. Check with `docker compose logs kaimon-edge-fe-anshar | grep kaimon-config`.

These values are baked into `/config.js` when the container starts, so changing them
only requires `docker compose up -d` — no image rebuild.

Notes:

- The video only plays when face detection is running, i.e. when KeyCardLess mode or
  anti-spoofing is on (KeyCardLess is on by default).
- `IDLE_VIDEO_MUTED=false` works on the kiosk because `start.sh` launches Chrome with
  `--autoplay-policy=no-user-gesture-required`; other browsers will block audible autoplay
  and the video will not start at all.

## Data

Persistent data is stored in `./data/`:

- `data/db/` — SQLite database
- `data/.deepface/` — Face recognition model cache
