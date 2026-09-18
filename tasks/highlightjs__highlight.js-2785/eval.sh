#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff a636dad242aaaa9fbb6abbd74915e2adb42d09ff
git checkout a636dad242aaaa9fbb6abbd74915e2adb42d09ff test/markup/php/comments.expect.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/php/comments.expect.txt b/test/markup/php/comments.expect.txt
index f02eb145db..fbbcbb1468 100644
--- a/test/markup/php/comments.expect.txt
+++ b/test/markup/php/comments.expect.txt
@@ -4,8 +4,8 @@
  * <span class="hljs-doctag">@param</span> int $a
  * <span class="hljs-doctag">@return</span> bool
  */</span>
-<span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">isEven</span>(<span class="hljs-params">$a</span>) </span>{
-    <span class="hljs-keyword">return</span> ($a % <span class="hljs-number">2</span>) === <span class="hljs-number">0</span>;
+<span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">isEven</span>(<span class="hljs-params"><span class="hljs-variable">$a</span></span>) </span>{
+    <span class="hljs-keyword">return</span> (<span class="hljs-variable">$a</span> % <span class="hljs-number">2</span>) === <span class="hljs-number">0</span>;
 }
 
 <span class="hljs-comment">/**
@@ -14,6 +14,6 @@
  * <span class="hljs-doctag">@param</span> int $a
  * <span class="hljs-doctag">@return</span> bool
  */</span>
-<span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">isOdd</span>(<span class="hljs-params">$a</span>) </span>{
-    <span class="hljs-keyword">return</span> ($a % <span class="hljs-number">2</span>) === <span class="hljs-number">1</span>;
+<span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">isOdd</span>(<span class="hljs-params"><span class="hljs-variable">$a</span></span>) </span>{
+    <span class="hljs-keyword">return</span> (<span class="hljs-variable">$a</span> % <span class="hljs-number">2</span>) === <span class="hljs-number">1</span>;
 }

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout a636dad242aaaa9fbb6abbd74915e2adb42d09ff test/markup/php/comments.expect.txt
