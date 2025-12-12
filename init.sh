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
mkdir -p /var/lib/ghost/content/themes
# Copy built-in themes if present
[ -d /var/lib/ghost/current/content/themes/source ] && cp -R /var/lib/ghost/current/content/themes/source /var/lib/ghost/content/themes/ 2>/dev/null || true
[ -d /var/lib/ghost/versions/6.10.2/content/themes/source ] && cp -R /var/lib/ghost/versions/6.10.2/content/themes/source /var/lib/ghost/content/themes/ 2>/dev/null || true
[ -d /var/lib/ghost/versions/6.10.2/content/themes/casper ] && cp -R /var/lib/ghost/versions/6.10.2/content/themes/casper /var/lib/ghost/content/themes/ 2>/dev/null || true

# Copy custom themes from repo (pushable)
if [ -d /opt/custom-themes ]; then
  cp -R /opt/custom-themes/* /var/lib/ghost/content/themes/ 2>/dev/null || true
fi
cd /var/lib/ghost
node current/index.js
