---
name: immich
description: Use when Zach asks about his photos, videos, albums, people, or anything in Immich (his self-hosted photo library). Covers the API URL, auth, and common calls.
---

# Immich

Immich runs on the NAS. The T3 Code container there uses host networking, so
from inside it Immich is at `127.0.0.1:2283`. Anywhere else, `IMMICH_URL` must
be set; if it is not and `127.0.0.1` does not answer, tell Zach Immich is not
reachable from this machine rather than guessing an address.

Key: `~/.config/immich/api-key` on the NAS (mode 600), or `IMMICH_API_KEY`
from Keychain on the Mac. Never print it.

```sh
IU=${IMMICH_URL:-http://127.0.0.1:2283}/api
IK=$(cat ~/.config/immich/api-key 2>/dev/null || security find-generic-password -s IMMICH_API_KEY -w)
im() { curl -s -H "x-api-key: $IK" -H "Content-Type: application/json" "$@"; }

im $IU/server/statistics
im $IU/albums
im $IU/people
im -X POST $IU/search/smart -d '{"query":"beach sunset","size":20}'
im -X POST $IU/search/metadata -d '{"takenAfter":"2025-01-01T00:00:00Z","size":50}'
im -o out.jpg "$IU/assets/<id>/thumbnail?size=preview"
```

The NAS container has no jq; parse JSON with `node -e` or `python3`.
For anything else, fetch `$IU/spec.json` and look up the path instead of
guessing.

Confirm with Zach before any delete, trash, or bulk edit.
