cat > start.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

node -e 'const fs=require("fs");const p="/openclaw/dist/agents/tools/web-search.js";let s=fs.readFileSync(p,"utf8");const old=`const BRAVE_SEARCH_ENDPOINT = "https://api.search.brave.com/res/v1/web/search";`;const neu=`const BRAVE_SEARCH_ENDPOINT = (process.env.BRAVE_SEARCH_ENDPOINT ?? "https://api.search.brave.com/res/v1/web/search").trim();`;if(!s.includes(neu)){if(!s.includes(old)){console.error("❌ Expected BRAVE_SEARCH_ENDPOINT line not found");process.exit(1);}fs.writeFileSync(p,s.replace(old,neu));console.log("✅ Patched BRAVE_SEARCH_ENDPOINT");}else{console.log("✅ Patch already present");}'

exec node src/server.js
SH

chmod +x start.sh
