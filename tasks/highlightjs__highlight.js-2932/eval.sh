#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 325c734213eee3be0c9fa5eca1bfc926185a074b
git checkout 325c734213eee3be0c9fa5eca1bfc926185a074b test/markup/properties/syntax.expect.txt test/markup/properties/syntax.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/properties/syntax.expect.txt b/test/markup/properties/syntax.expect.txt
index 45b473a320..5281acd45e 100644
--- a/test/markup/properties/syntax.expect.txt
+++ b/test/markup/properties/syntax.expect.txt
@@ -12,3 +12,9 @@
       val</span>
 <span class="hljs-attr">key\ key\:\=</span> <span class="hljs-string">val</span>
 <span class="hljs-attr">key</span>
+<span class="hljs-comment"># if the number of backslashes at the end of the line is even, the next line is not included in the value</span>
+<span class="hljs-attr">key</span> = <span class="hljs-string">val\\</span>
+<span class="hljs-attr">key</span> = <span class="hljs-string">diffValue\\\\</span>
+<span class="hljs-comment"># val with odd number of backslash, here val2 is part of the key</span>
+<span class="hljs-attr">key</span> = <span class="hljs-string">val\\\
+      val2</span>
diff --git a/test/markup/properties/syntax.txt b/test/markup/properties/syntax.txt
index 76a4a2b1cc..d85b04971b 100644
--- a/test/markup/properties/syntax.txt
+++ b/test/markup/properties/syntax.txt
@@ -12,3 +12,9 @@ key = val\
       val
 key\ key\:\= val
 key
+# if the number of backslashes at the end of the line is even, the next line is not included in the value
+key = val\\
+key = diffValue\\\\
+# val with odd number of backslash, here val2 is part of the key
+key = val\\\
+      val2

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 325c734213eee3be0c9fa5eca1bfc926185a074b test/markup/properties/syntax.expect.txt test/markup/properties/syntax.txt
