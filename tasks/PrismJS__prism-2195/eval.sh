#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 0bf73dc7813cdd1eadb15730d8c9f2d00f208df8
git checkout 0bf73dc7813cdd1eadb15730d8c9f2d00f208df8 tests/languages/visual-basic/comment_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/visual-basic/comment_feature.test b/tests/languages/visual-basic/comment_feature.test
index 41e14eaa1b..af3edcdb65 100644
--- a/tests/languages/visual-basic/comment_feature.test
+++ b/tests/languages/visual-basic/comment_feature.test
@@ -7,6 +7,9 @@
 REM
 REM Foobar
 
+' multi-line _
+  comment
+
 ----------------------------------------------------
 
 [
@@ -17,9 +20,10 @@ REM Foobar
 	["comment", ["’"]],
 	["comment", ["’ Foobar"]],
 	["comment", [["keyword", "REM"]]],
-	["comment", [["keyword", "REM"], " Foobar"]]
+	["comment", [["keyword", "REM"], " Foobar"]],
+	["comment", ["' multi-line _\r\n  comment"]]
 ]
 
 ----------------------------------------------------
 
-Checks for comments.
\ No newline at end of file
+Checks for comments.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language visual-basic
: '>>>>> End Test Output'
git checkout 0bf73dc7813cdd1eadb15730d8c9f2d00f208df8 tests/languages/visual-basic/comment_feature.test
