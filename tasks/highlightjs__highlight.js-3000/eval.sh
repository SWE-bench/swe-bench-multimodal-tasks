#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff eb742fd66a325dfe1139370417148375833c4010
git checkout eb742fd66a325dfe1139370417148375833c4010 test/markup/php/comments.expect.txt && rm -f test/markup/php/functions.expect.txt test/markup/php/functions.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/php/comments.expect.txt b/test/markup/php/comments.expect.txt
index fbbcbb1468..c477b66da6 100644
--- a/test/markup/php/comments.expect.txt
+++ b/test/markup/php/comments.expect.txt
@@ -17,3 +17,4 @@
 <span class="hljs-function"><span class="hljs-keyword">function</span> <span class="hljs-title">isOdd</span>(<span class="hljs-params"><span class="hljs-variable">$a</span></span>) </span>{
     <span class="hljs-keyword">return</span> (<span class="hljs-variable">$a</span> % <span class="hljs-number">2</span>) === <span class="hljs-number">1</span>;
 }
+
diff --git a/test/markup/php/functions.expect.txt b/test/markup/php/functions.expect.txt
new file mode 100644
index 0000000000..d161e753f4
--- /dev/null
+++ b/test/markup/php/functions.expect.txt
@@ -0,0 +1,8 @@
+<span class="hljs-comment">/**
+ * Arrow functions
+ */</span>
+<span class="hljs-variable">$fn1</span> = <span class="hljs-function"><span class="hljs-keyword">fn</span>(<span class="hljs-params"><span class="hljs-variable">$x</span></span>) =&gt;</span> <span class="hljs-variable">$x</span> + <span class="hljs-variable">$y</span>;
+
+<span class="hljs-variable">$fn2</span> = <span class="hljs-function"><span class="hljs-keyword">function</span> (<span class="hljs-params"><span class="hljs-variable">$x</span></span>) <span class="hljs-keyword">use</span> (<span class="hljs-params"><span class="hljs-variable">$y</span></span>) </span>{
+    <span class="hljs-keyword">return</span> <span class="hljs-variable">$x</span> + <span class="hljs-variable">$y</span>;
+};
diff --git a/test/markup/php/functions.txt b/test/markup/php/functions.txt
new file mode 100644
index 0000000000..2eec171beb
--- /dev/null
+++ b/test/markup/php/functions.txt
@@ -0,0 +1,8 @@
+/**
+ * Arrow functions
+ */
+$fn1 = fn($x) => $x + $y;
+
+$fn2 = function ($x) use ($y) {
+    return $x + $y;
+};

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout eb742fd66a325dfe1139370417148375833c4010 test/markup/php/comments.expect.txt && rm -f test/markup/php/functions.expect.txt test/markup/php/functions.txt
