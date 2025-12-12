#!/bin/sh
set -eu
export database__client=sqlite3
export database__connection__filename=/var/lib/ghost/content/data/ghost.db
export server__host=0.0.0.0
export server__port=${PORT:-2368}
export url=${RENDER_EXTERNAL_URL:-http://localhost:${server__port}}
if [ "${GIT_AUTO_PUSH:-}" = "1" ]; then
  REPO_ROOT="${REPO_ROOT:-$(pwd)}"
  WATCH_FILE="${WATCH_FILE:-$0}"
  LOG_FILE="${GIT_WATCH_LOG:-/var/lib/ghost/content/logs/git-watch.log}"
  mkdir -p /var/lib/ghost/content/logs
  touch "$LOG_FILE" 2>/dev/null || true
  (
    prev=""
    while true; do
      ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      if stat -f %m "$WATCH_FILE" >/dev/null 2>&1; then
        cur="$(stat -f %m "$WATCH_FILE")"
      else
        cur="$(stat -c %Y "$WATCH_FILE" 2>/dev/null || echo "")"
      fi
      if [ -n "$cur" ] && [ "$cur" != "$prev" ]; then
        echo "$ts change detected: $WATCH_FILE" | tee -a "$LOG_FILE" >/dev/null
        if [ -d "$REPO_ROOT/.git" ]; then
          if [ -n "$(git -C \"$REPO_ROOT\" diff --name-only -- init.sh)" ]; then
            echo "$ts git add init.sh" | tee -a "$LOG_FILE" >/dev/null
            git -C "$REPO_ROOT" add init.sh || true
            echo "$ts git commit" | tee -a "$LOG_FILE" >/dev/null
            git -C "$REPO_ROOT" commit -m "auto: update init.sh" --no-verify || true
            echo "$ts git push" | tee -a "$LOG_FILE" >/dev/null
            git -C "$REPO_ROOT" push || true
          else
            echo "$ts no diff for init.sh" >> "$LOG_FILE" 2>/dev/null || true
          fi
        else
          echo "$ts no .git in $REPO_ROOT" >> "$LOG_FILE" 2>/dev/null || true
        fi
        prev="$cur"
      fi
      sleep 2
    done
  ) &
fi
mkdir -p /var/lib/ghost/content/data
mkdir -p /var/lib/ghost/content/logs
mkdir -p /var/lib/ghost/content/public
mkdir -p /var/lib/ghost/content/settings
mkdir -p /var/lib/ghost/content/themes
[ -d /var/lib/ghost/current/content/themes/source ] && cp -R /var/lib/ghost/current/content/themes/source /var/lib/ghost/content/themes/ 2>/dev/null || true
[ -d /var/lib/ghost/versions/6.10.2/content/themes/source ] && cp -R /var/lib/ghost/versions/6.10.2/content/themes/source /var/lib/ghost/content/themes/ 2>/dev/null || true
[ -d /var/lib/ghost/versions/6.10.2/content/themes/casper ] && cp -R /var/lib/ghost/versions/6.10.2/content/themes/casper /var/lib/ghost/content/themes/ 2>/dev/null || true
if [ -d /opt/custom-themes ]; then
  cp -R /opt/custom-themes/* /var/lib/ghost/content/themes/ 2>/dev/null || true
fi
cd /var/lib/ghost
node current/index.js
