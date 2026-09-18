#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 7bcec58460c7d635841058fc9722a13b9790016a
git checkout 7bcec58460c7d635841058fc9722a13b9790016a tests/languages/smalltalk/comment_feature.test tests/languages/smalltalk/string_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/smalltalk/comment_feature.test b/tests/languages/smalltalk/comment_feature.test
index 844e7ba3d1..4b0e1251f7 100644
--- a/tests/languages/smalltalk/comment_feature.test
+++ b/tests/languages/smalltalk/comment_feature.test
@@ -1,14 +1,16 @@
 "foobar"
 "foo""bar
 baz"
+""
 
 ----------------------------------------------------
 
 [
 	["comment", "\"foobar\""],
-	["comment", "\"foo\"\"bar\r\nbaz\""]
+	["comment", "\"foo\"\"bar\r\nbaz\""],
+	["comment", "\"\""]
 ]
 
 ----------------------------------------------------
 
-Checks for comments.
\ No newline at end of file
+Checks for comments.
diff --git a/tests/languages/smalltalk/string_feature.test b/tests/languages/smalltalk/string_feature.test
index cd832ddda1..8eaeba1434 100644
--- a/tests/languages/smalltalk/string_feature.test
+++ b/tests/languages/smalltalk/string_feature.test
@@ -1,14 +1,16 @@
 'foobar'
 'foo''bar
 baz'
+''
 
 ----------------------------------------------------
 
 [
 	["string", "'foobar'"],
-	["string", "'foo''bar\r\nbaz'"]
+	["string", "'foo''bar\r\nbaz'"],
+	["string", "''"]
 ]
 
 ----------------------------------------------------
 
-Checks for strings.
\ No newline at end of file
+Checks for strings.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language smalltalk
: '>>>>> End Test Output'
git checkout 7bcec58460c7d635841058fc9722a13b9790016a tests/languages/smalltalk/comment_feature.test tests/languages/smalltalk/string_feature.test
