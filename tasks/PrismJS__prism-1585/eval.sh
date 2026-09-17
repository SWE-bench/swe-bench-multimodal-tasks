#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 11695629f12925c586702453beaee5f4825d0ebd
git checkout 11695629f12925c586702453beaee5f4825d0ebd tests/languages/css/important_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/css/important_feature.test b/tests/languages/css/important_feature.test
index ad69c39a43..0f5c1409e9 100644
--- a/tests/languages/css/important_feature.test
+++ b/tests/languages/css/important_feature.test
@@ -1,5 +1,6 @@
 color: red !important;
 padding: 10px 20px 30px !important;
+position:absolute!important;
 
 ----------------------------------------------------
 
@@ -10,12 +11,17 @@ padding: 10px 20px 30px !important;
 	["important", "!important"],
 	["punctuation", ";"],
 	["property", "padding"],
-    ["punctuation", ":"],
-    " 10px 20px 30px ",
-    ["important", "!important"],
-    ["punctuation", ";"]
+	["punctuation", ":"],
+	" 10px 20px 30px ",
+	["important", "!important"],
+	["punctuation", ";"],
+	["property", "position"],
+	["punctuation", ":"],
+	"absolute",
+	["important", "!important"],
+	["punctuation", ";"]
 ]
 
 ----------------------------------------------------
 
-Checks for !important rule.
\ No newline at end of file
+Checks for !important rule.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language css
: '>>>>> End Test Output'
git checkout 11695629f12925c586702453beaee5f4825d0ebd tests/languages/css/important_feature.test
