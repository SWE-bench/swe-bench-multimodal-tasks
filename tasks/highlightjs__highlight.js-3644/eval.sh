#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 71f5cb2970e26e0b7f9b115368cfff1e13a97fd3
git checkout 71f5cb2970e26e0b7f9b115368cfff1e13a97fd3 test/markup/cmake/default.expect.txt test/markup/cmake/default.txt
git apply -v - <<'EOF_114329324912'
diff --git a/test/markup/cmake/default.expect.txt b/test/markup/cmake/default.expect.txt
index 638923c572..fd6c45401d 100644
--- a/test/markup/cmake/default.expect.txt
+++ b/test/markup/cmake/default.expect.txt
@@ -17,3 +17,7 @@
 
 <span class="hljs-keyword">add_executable</span>(myproject main.cpp mainwindow.cpp)
 <span class="hljs-keyword">qt5_use_modules</span>(myproject Widgets)
+
+<span class="hljs-comment">#[[This is a bracket comment.
+It runs until the close bracket.]]</span>
+<span class="hljs-keyword">message</span>(<span class="hljs-string">&quot;First Argument\n&quot;</span> <span class="hljs-comment">#[[Bracket Comment]]</span> <span class="hljs-string">&quot;Second Argument&quot;</span>)
diff --git a/test/markup/cmake/default.txt b/test/markup/cmake/default.txt
index 2bbea38c9d..1f4d7faa69 100644
--- a/test/markup/cmake/default.txt
+++ b/test/markup/cmake/default.txt
@@ -17,3 +17,7 @@ find_package(Qt5Widgets REQUIRED)
 
 add_executable(myproject main.cpp mainwindow.cpp)
 qt5_use_modules(myproject Widgets)
+
+#[[This is a bracket comment.
+It runs until the close bracket.]]
+message("First Argument\n" #[[Bracket Comment]] "Second Argument")

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
npm run build ; npm run test
: '>>>>> End Test Output'
git checkout 71f5cb2970e26e0b7f9b115368cfff1e13a97fd3 test/markup/cmake/default.expect.txt test/markup/cmake/default.txt
