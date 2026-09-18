#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff acceb3b56f0e8362a7ef274dbd85b17611df2ec4
rm -f tests/languages/cpp/number_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/cpp/number_feature.test b/tests/languages/cpp/number_feature.test
new file mode 100644
index 0000000000..47d15d9a61
--- /dev/null
+++ b/tests/languages/cpp/number_feature.test
@@ -0,0 +1,64 @@
+42
+3.14159
+4e10
+2.1e-10
+0.4e+2
+0xbabe
+0xBABE
+0x1.2
+0x0.3p-3
+0x0.3p4L
+42f
+42F
+42u
+42U
+42l
+42L
+0b0101
+0B0101
+
+18446744073709550592ull
+18'446'744'073'709'550'592llu
+1844'6744'0737'0955'0592uLL
+184467'440737'0'95505'92LLU
+1'048'576
+0x10'0000
+0'004'000'000
+1.602'176'565e-19
+0b010'01010
+
+----------------------------------------------------
+
+[
+	["number", "42"],
+	["number", "3.14159"],
+	["number", "4e10"],
+	["number", "2.1e-10"],
+	["number", "0.4e+2"],
+	["number", "0xbabe"],
+	["number", "0xBABE"],
+	["number", "0x1.2"],
+	["number", "0x0.3p-3"],
+	["number", "0x0.3p4L"],
+	["number", "42f"],
+	["number", "42F"],
+	["number", "42u"],
+	["number", "42U"],
+	["number", "42l"],
+	["number", "42L"],
+	["number", "0b0101"],
+	["number", "0B0101"],
+	["number", "18446744073709550592ull"],
+	["number", "18'446'744'073'709'550'592llu"],
+	["number", "1844'6744'0737'0955'0592uLL"],
+	["number", "184467'440737'0'95505'92LLU"],
+	["number", "1'048'576"],
+	["number", "0x10'0000"],
+	["number", "0'004'000'000"],
+	["number", "1.602'176'565e-19"],
+	["number", "0b010'01010"]
+]
+
+----------------------------------------------------
+
+Checks for binary, decimal, and hexadecimal numbers.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language cpp
: '>>>>> End Test Output'
rm -f tests/languages/cpp/number_feature.test
