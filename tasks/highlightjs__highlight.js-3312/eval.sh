#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 51d4c1b0871be337eeb6c651c9b41bc9529c37c1
rm -f test/markup/cpp/function-like-keywords.expect.txt test/markup/cpp/function-like-keywords.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/cpp/function-like-keywords.expect.txt b/test/markup/cpp/function-like-keywords.expect.txt
new file mode 100644
index 0000000000..f58427e223
--- /dev/null
+++ b/test/markup/cpp/function-like-keywords.expect.txt
@@ -0,0 +1,7 @@
+<span class="hljs-keyword">if</span> (ch) {}
+
+<span class="hljs-keyword">switch</span> (ch) {}
+
+<span class="hljs-keyword">while</span> (ch) {}
+
+<span class="hljs-keyword">for</span> (;;) {}
diff --git a/test/markup/cpp/function-like-keywords.txt b/test/markup/cpp/function-like-keywords.txt
new file mode 100644
index 0000000000..514676c0a0
--- /dev/null
+++ b/test/markup/cpp/function-like-keywords.txt
@@ -0,0 +1,8 @@
+
+if (ch) {}
+
+switch (ch) {}
+
+while (ch) {}
+
+for (;;) {}

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
rm -f test/markup/cpp/function-like-keywords.expect.txt test/markup/cpp/function-like-keywords.txt
