#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 293dce42ff8911b508cb904a6f7a6b3283e1e85c
git checkout 293dce42ff8911b508cb904a6f7a6b3283e1e85c tests/languages/css/atrule_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/css/atrule_feature.test b/tests/languages/css/atrule_feature.test
index adb84ab093..d5ca5d2c1e 100644
--- a/tests/languages/css/atrule_feature.test
+++ b/tests/languages/css/atrule_feature.test
@@ -4,6 +4,7 @@
 @supports (top: 50vmax)
 	or (top: 50vw) {}
 @main-color: red;
+@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
 
 ----------------------------------------------------
 
@@ -18,12 +19,14 @@
 		]],
 		["punctuation", ";"]
 	]],
+
 	["atrule", [
 		["rule", "@media"],
 		" print"
 	]],
 	["punctuation", "{"],
 	["punctuation", "}"],
+
 	["atrule", [
 		["rule", "@media"],
 		["punctuation", "("],
@@ -40,6 +43,7 @@
 	]],
 	["punctuation", "{"],
 	["punctuation", "}"],
+
 	["atrule", [
 		["rule", "@supports"],
 		["punctuation", "("],
@@ -47,6 +51,7 @@
 		["punctuation", ":"],
 		" 50vmax",
 		["punctuation", ")"],
+
 		["keyword", "or"],
 		["punctuation", "("],
 		["property", "top"],
@@ -56,11 +61,23 @@
 	]],
 	["punctuation", "{"],
 	["punctuation", "}"],
+
 	["atrule", [
 		["rule", "@main-color"],
 		["punctuation", ":"],
 		" red",
 		["punctuation", ";"]
+	]],
+
+	["atrule", [
+		["rule", "@import"],
+		["url", [
+			["function", "url"],
+			["punctuation", "("],
+			["string", "'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap'"],
+			["punctuation", ")"]
+		]],
+		["punctuation", ";"]
 	]]
 ]
 

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language css
: '>>>>> End Test Output'
git checkout 293dce42ff8911b508cb904a6f7a6b3283e1e85c tests/languages/css/atrule_feature.test
