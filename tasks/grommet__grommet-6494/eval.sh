#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 67795aab20a077639a475a7e718e55f423f6dffc
git checkout 67795aab20a077639a475a7e718e55f423f6dffc src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap
git apply -v - <<'EOF_114329324912'
diff --git a/src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap b/src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap
index 63219adcb3..b272c41761 100644
--- a/src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap
+++ b/src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap
@@ -21,6 +21,7 @@ exports[`RangeInput onBlur 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -165,6 +166,7 @@ exports[`RangeInput onChange 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -309,6 +311,7 @@ exports[`RangeInput onFocus 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -507,6 +510,7 @@ exports[`RangeInput renders 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -651,6 +655,7 @@ exports[`RangeInput should have no accessibility violations 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -796,6 +801,7 @@ exports[`RangeInput track themed 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -940,6 +946,7 @@ exports[`RangeInput track themed with color and opacity 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -1084,6 +1091,7 @@ exports[`RangeInput with min and max offset 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -1228,6 +1236,7 @@ exports[`RangeInput with multi color 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {
@@ -1373,6 +1382,7 @@ exports[`RangeInput with single color 1`] = `
   padding: 0px;
   cursor: pointer;
   background: transparent;
+  margin: 0px;
 }
 
 .c1::-moz-focus-inner {

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
yarn test
: '>>>>> End Test Output'
git checkout 67795aab20a077639a475a7e718e55f423f6dffc src/js/components/RangeInput/__tests__/__snapshots__/RangeInput-test.tsx.snap
