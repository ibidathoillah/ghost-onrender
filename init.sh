#!/bin/sh
set -eu
export database__client=sqlite3
export database__connection__filename=/var/lib/ghost/content/data/ghost.db
export server__host=0.0.0.0
export server__port=${PORT:-2368}
export url=${RENDER_EXTERNAL_URL:-http://localhost:${server__port}}
mkdir -p /var/lib/ghost/content/data
mkdir -p /var/lib/ghost/content/logs
mkdir -p /var/lib/ghost/content/public
mkdir -p /var/lib/ghost/content/settings
cd /var/lib/ghost
node current/index.js
