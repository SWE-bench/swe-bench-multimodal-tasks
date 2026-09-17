#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 006a478fb62b7b7928dbe9d2756cd76e56ee592c
rm -f test/markup/xml/namespace.expect.txt test/markup/xml/namespace.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/xml/namespace.expect.txt b/test/markup/xml/namespace.expect.txt
new file mode 100644
index 0000000000..4317227c5f
--- /dev/null
+++ b/test/markup/xml/namespace.expect.txt
@@ -0,0 +1,3 @@
+<span class="hljs-meta">&lt;?xml version=&quot;1.0&quot; encoding=&quot;ISO-8859-1&quot; ?&gt;</span>
+<span class="hljs-tag">&lt;<span class="hljs-name">xs:schema</span> <span class="hljs-attr">xmlns:xs</span>=<span class="hljs-string">&quot;http://www.w3.org/2001/XMLSchema&quot;</span>&gt;</span><span class="hljs-tag">&lt;/<span class="hljs-name">xs:schema</span>&gt;</span>
+<span class="hljs-tag">&lt;<span class="hljs-name">s:schema</span> <span class="hljs-attr">xmlns:s</span>=<span class="hljs-string">&quot;http://www.w3.org/2001/XMLSchema&quot;</span>&gt;</span><span class="hljs-tag">&lt;/<span class="hljs-name">s:schema</span>&gt;</span>
diff --git a/test/markup/xml/namespace.txt b/test/markup/xml/namespace.txt
new file mode 100644
index 0000000000..043bd9937f
--- /dev/null
+++ b/test/markup/xml/namespace.txt
@@ -0,0 +1,3 @@
+<?xml version="1.0" encoding="ISO-8859-1" ?>
+<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"></xs:schema>
+<s:schema xmlns:s="http://www.w3.org/2001/XMLSchema"></s:schema>

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/xml/namespace.expect.txt test/markup/xml/namespace.txt
