#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 777eb9172f9cabb96acf82d204769059ca2d0030
git checkout 777eb9172f9cabb96acf82d204769059ca2d0030 test/markup/markdown/bold_italics.expect.txt test/markup/markdown/bold_italics.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/markdown/bold_italics.expect.txt b/test/markup/markdown/bold_italics.expect.txt
index d9db053a7f..ddc8a59558 100644
--- a/test/markup/markdown/bold_italics.expect.txt
+++ b/test/markup/markdown/bold_italics.expect.txt
@@ -16,3 +16,6 @@
 
 <span class="hljs-bullet">*</span> list with a <span class="hljs-emphasis">*italic item*</span>
 <span class="hljs-bullet">*</span> list with a <span class="hljs-strong">**bold item**</span>
+
+<span class="hljs-strong">**<span class="hljs-emphasis">*This is bold and italic*</span>**</span>
+<span class="hljs-strong">__<span class="hljs-emphasis">_This is bold and italic_</span>__</span>
diff --git a/test/markup/markdown/bold_italics.txt b/test/markup/markdown/bold_italics.txt
index 2b72d45cdd..5f15ea0d7b 100644
--- a/test/markup/markdown/bold_italics.txt
+++ b/test/markup/markdown/bold_italics.txt
@@ -16,3 +16,6 @@ __Bold *then italic*__
 
 * list with a *italic item*
 * list with a **bold item**
+
+***This is bold and italic***
+___This is bold and italic___

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 777eb9172f9cabb96acf82d204769059ca2d0030 test/markup/markdown/bold_italics.expect.txt test/markup/markdown/bold_italics.txt
