#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 2b6a9e974daab86764b19f764aa7f497e0e969f8
rm -f test/markup/javascript/built-in.expect.txt test/markup/javascript/built-in.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/javascript/built-in.expect.txt b/test/markup/javascript/built-in.expect.txt
new file mode 100644
index 0000000000..c606a244e7
--- /dev/null
+++ b/test/markup/javascript/built-in.expect.txt
@@ -0,0 +1,4 @@
+<span class="hljs-keyword">let</span> bi = <span class="hljs-built_in">BigInt</span>(<span class="hljs-string">&#x27;1&#x27;</span>);
+<span class="hljs-keyword">let</span> inf = <span class="hljs-literal">Infinity</span>
+<span class="hljs-built_in">Number</span>(<span class="hljs-literal">undefined</span>)
+<span class="hljs-keyword">let</span> today = <span class="hljs-keyword">new</span> <span class="hljs-built_in">Date</span>()
\ No newline at end of file
diff --git a/test/markup/javascript/built-in.txt b/test/markup/javascript/built-in.txt
new file mode 100644
index 0000000000..59bf8299a2
--- /dev/null
+++ b/test/markup/javascript/built-in.txt
@@ -0,0 +1,4 @@
+let bi = BigInt('1');
+let inf = Infinity
+Number(undefined)
+let today = new Date()
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/javascript/built-in.expect.txt test/markup/javascript/built-in.txt
