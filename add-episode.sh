#!/usr/bin/env bash
# Usage: ./add-episode.sh "Episode Title" "https://audio-url.mp3" [YYYY-MM-DD]
set -e

TITLE="$1"
URL="$2"
DATE="${3:-$(date +%Y-%m-%d)}"
DATA_FILE="$(dirname "$0")/data/episodes.json"

if [[ -z "$TITLE" || -z "$URL" ]]; then
  echo "Usage: ./add-episode.sh \"Episode Title\" \"https://audio-url.mp3\" [YYYY-MM-DD]"
  exit 1
fi

python3 - "$TITLE" "$URL" "$DATE" "$DATA_FILE" <<'EOF'
import json, sys

title, url, date, path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(path) as f:
    episodes = json.load(f)

episodes.insert(0, {"title": title, "url": url, "date": date})

with open(path, "w") as f:
    json.dump(episodes, f, indent=2)
    f.write("\n")

print(f"Added: {title}")
EOF

cd "$(dirname "$0")"
git add data/episodes.json
git commit -m "Add episode: $TITLE"
git push
echo "Pushed to GitHub."
