#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 1166e6875e719e2324a3d4a8179a907bc6cefe98
git checkout 1166e6875e719e2324a3d4a8179a907bc6cefe98 test/markup/dart/comment-markdown.expect.txt test/markup/dart/comment-markdown.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/dart/comment-markdown.expect.txt b/test/markup/dart/comment-markdown.expect.txt
index b983b1c162..ed87e583ff 100644
--- a/test/markup/dart/comment-markdown.expect.txt
+++ b/test/markup/dart/comment-markdown.expect.txt
@@ -5,5 +5,10 @@
 <span class="hljs-comment">/// <span class="markdown"><span class="hljs-code">code;</span></span></span>
 <span class="hljs-comment">/// <span class="markdown"><span class="hljs-code">```</span></span></span>
 <span class="hljs-comment">/// <span class="markdown">text.</span></span>
+<span class="hljs-comment">/// <span class="markdown"><span class="hljs-bullet">*</span> bullet</span></span>
+<span class="hljs-comment">/// <span class="markdown"><span class="hljs-bullet">  *</span> sub-bullet</span></span>
 
-<span class="hljs-comment">/// <span class="markdown">Comment 3.</span></span>
+<span class="hljs-comment">///</span>
+code;
+
+<span class="hljs-comment">/**/</span>code;
diff --git a/test/markup/dart/comment-markdown.txt b/test/markup/dart/comment-markdown.txt
index 06d907b862..ed9318a78f 100644
--- a/test/markup/dart/comment-markdown.txt
+++ b/test/markup/dart/comment-markdown.txt
@@ -5,5 +5,10 @@
 /// code;
 /// ```
 /// text.
+/// * bullet
+///   * sub-bullet
 
-/// Comment 3.
+///
+code;
+
+/**/code;

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 1166e6875e719e2324a3d4a8179a907bc6cefe98 test/markup/dart/comment-markdown.expect.txt test/markup/dart/comment-markdown.txt
