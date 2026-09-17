#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff f0a10669acd07ddcd88eccef2675f488068c98e9
git checkout f0a10669acd07ddcd88eccef2675f488068c98e9 tests/languages/javascript/number_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/javascript/number_feature.test b/tests/languages/javascript/number_feature.test
index 16f0e5fdf3..817a7b0d68 100644
--- a/tests/languages/javascript/number_feature.test
+++ b/tests/languages/javascript/number_feature.test
@@ -7,11 +7,22 @@
 0o571
 0xbabe
 0xBABE
+
 NaN
 Infinity
+
 123n
 0x123n
 
+1_000_000_000_000
+1_000_000.220_720
+0b0101_0110_0011_1000
+0o12_34_56
+0x40_76_38_6A_73
+4_642_473_943_484_686_707n
+0.000_001
+1e10_000
+
 ----------------------------------------------------
 
 [
@@ -27,7 +38,15 @@ Infinity
 	["number", "NaN"],
 	["number", "Infinity"],
 	["number", "123n"],
-	["number", "0x123n"]
+	["number", "0x123n"],
+	["number", "1_000_000_000_000"],
+	["number", "1_000_000.220_720"],
+	["number", "0b0101_0110_0011_1000"],
+	["number", "0o12_34_56"],
+	["number", "0x40_76_38_6A_73"],
+	["number", "4_642_473_943_484_686_707n"],
+	["number", "0.000_001"],
+	["number", "1e10_000"]
 ]
 
 ----------------------------------------------------

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language javascript
: '>>>>> End Test Output'
git checkout f0a10669acd07ddcd88eccef2675f488068c98e9 tests/languages/javascript/number_feature.test
