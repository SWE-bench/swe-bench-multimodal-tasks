#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff b85f4ab83bff5744b0f2c3a842706a382c51d99f
git checkout b85f4ab83bff5744b0f2c3a842706a382c51d99f test/markup/python/function-header.expect.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/python/function-header.expect.txt b/test/markup/python/function-header.expect.txt
index 832816bfd9..197b91d7cd 100644
--- a/test/markup/python/function-header.expect.txt
+++ b/test/markup/python/function-header.expect.txt
@@ -1,2 +1,2 @@
-<span class="hljs-function"><span class="hljs-keyword">def</span> <span class="hljs-title">f</span>(<span class="hljs-params">x: <span class="hljs-built_in">int</span>, *, y: <span class="hljs-built_in">bool</span> = <span class="hljs-literal">True</span></span>) -&gt; <span class="hljs-keyword">None</span>:</span>
+<span class="hljs-function"><span class="hljs-keyword">def</span> <span class="hljs-title">f</span>(<span class="hljs-params">x: <span class="hljs-built_in">int</span>, *, y: <span class="hljs-built_in">bool</span> = <span class="hljs-literal">True</span></span>) -&gt; <span class="hljs-literal">None</span>:</span>
     <span class="hljs-keyword">pass</span>

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout b85f4ab83bff5744b0f2c3a842706a382c51d99f test/markup/python/function-header.expect.txt
