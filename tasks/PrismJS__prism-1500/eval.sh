#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 9d15ff6ee48f2e8b9df836832590070855d969d1
git checkout 9d15ff6ee48f2e8b9df836832590070855d969d1 tests/languages/sql/string_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/sql/string_feature.test b/tests/languages/sql/string_feature.test
index 054040cf37..3dfeb990a9 100644
--- a/tests/languages/sql/string_feature.test
+++ b/tests/languages/sql/string_feature.test
@@ -6,6 +6,8 @@ bar"
 'fo\'obar'
 'foo
 bar'
+'foo''s bar'
+"foo's ""bar"""
 
 ----------------------------------------------------
 
@@ -15,9 +17,11 @@ bar'
 	["string", "\"foo\r\nbar\""],
 	["string", "''"],
 	["string", "'fo\\'obar'"],
-	["string", "'foo\r\nbar'"]
+	["string", "'foo\r\nbar'"],
+	["string", "'foo''s bar'"],
+	["string", "\"foo's \"\"bar\"\"\""]
 ]
 
 ----------------------------------------------------
 
-Checks for strings.
\ No newline at end of file
+Checks for strings.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language sql
: '>>>>> End Test Output'
git checkout 9d15ff6ee48f2e8b9df836832590070855d969d1 tests/languages/sql/string_feature.test
