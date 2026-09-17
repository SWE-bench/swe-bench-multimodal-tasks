#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff fdd291c0577771ff533a602d31022f6a6306d886
rm -f tests/languages/typescript/issue3000.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/typescript/issue3000.test b/tests/languages/typescript/issue3000.test
new file mode 100644
index 0000000000..0617bd2ed9
--- /dev/null
+++ b/tests/languages/typescript/issue3000.test
@@ -0,0 +1,51 @@
+import { infer, inference, infer } from 'module'
+//              ~~~~~ ✅
+
+import { type, typeDefs, type } from 'module'
+//             ~~~~ ✅
+
+import { const, constants, const } from 'module'
+//              ~~~~~ ✅
+
+----------------------------------------------------
+
+[
+	["keyword", "import"],
+	["punctuation", "{"],
+	" infer",
+	["punctuation", ","],
+	" inference",
+	["punctuation", ","],
+	" infer ",
+	["punctuation", "}"],
+	["keyword", "from"],
+	["string", "'module'"],
+
+	["comment", "//              ~~~~~ ✅"],
+
+	["keyword", "import"],
+	["punctuation", "{"],
+	" type",
+	["punctuation", ","],
+	" typeDefs",
+	["punctuation", ","],
+	" type ",
+	["punctuation", "}"],
+	["keyword", "from"],
+	["string", "'module'"],
+
+	["comment", "//             ~~~~ ✅"],
+
+	["keyword", "import"],
+	["punctuation", "{"],
+	["keyword", "const"],
+	["punctuation", ","],
+	" constants",
+	["punctuation", ","],
+	["keyword", "const"],
+	["punctuation", "}"],
+	["keyword", "from"],
+	["string", "'module'"],
+
+	["comment", "//              ~~~~~ ✅"]
+]

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language typescript
: '>>>>> End Test Output'
rm -f tests/languages/typescript/issue3000.test
