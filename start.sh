#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure 'moltbot' command exists (some wrapper paths still call it)
if command -v openclaw >/dev/null 2>&1; then
  ln -sf "$(command -v openclaw)" /usr/local/bin/moltbot || true
fi

# 2) Ensure wrapper config path exists
mkdir -p /data/.clawdbot
ln -sf /data/.clawdbot/moltbot.json /data/.clawdbot/openclaw.json || true

# 3) Patch web-search.js to allow BRAVE_SEARCH_ENDPOINT override (safe if already patched)
node -e '
const fs=require("fs");
const p="/openclaw/dist/agents/tools/web-search.js";
let s=fs.readFileSync(p,"utf8");
const oldLine=`const BRAVE_SEARCH_ENDPOINT = "https://api.search.brave.com/res/v1/web/search";`;
const newLine=`const BRAVE_SEARCH_ENDPOINT = (process.env.BRAVE_SEARCH_ENDPOINT ?? "https://api.search.brave.com/res/v1/web/search").trim();`;
if (s.includes(newLine)) {
  console.log("✅ Patch already present");
} else if (s.includes(oldLine)) {
  fs.writeFileSync(p, s.replace(oldLine, newLine));
  console.log("✅ Patched BRAVE_SEARCH_ENDPOINT");
} else {
  console.log("⚠️ Could not find expected BRAVE_SEARCH_ENDPOINT line (continuing anyway)");
}
'

# 4) Start wrapper server
exec node src/server.js
