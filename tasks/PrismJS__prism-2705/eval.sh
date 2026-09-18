#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 729627012e9ca7a3cd99aa49619bda4c0ae0df8e
rm -f tests/languages/javascript/issue2694.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/javascript/issue2694.test b/tests/languages/javascript/issue2694.test
new file mode 100644
index 0000000000..53c06c9a2a
--- /dev/null
+++ b/tests/languages/javascript/issue2694.test
@@ -0,0 +1,70 @@
+replace(/'/, `'`)
+
+const var1 = `this is fine`;
+const var2 = `this is fine`;
+
+// `load bearing comment`
+
+const var3 = `break starts here`;
+const var4 = `break ends here`;
+
+----------------------------------------------------
+
+[
+	["function", "replace"],
+	["punctuation", "("],
+	["regex", [
+		["regex-delimiter", "/"],
+		["regex-source", "'"],
+		["regex-delimiter", "/"]
+	]],
+	["punctuation", ","],
+	["template-string", [
+		["template-punctuation", "`"],
+		["string", "'"],
+		["template-punctuation", "`"]
+	]],
+	["punctuation", ")"],
+
+	["keyword", "const"],
+	" var1 ",
+	["operator", "="],
+	["template-string", [
+		["template-punctuation", "`"],
+		["string", "this is fine"],
+		["template-punctuation", "`"]
+	]],
+	["punctuation", ";"],
+
+	["keyword", "const"],
+	" var2 ",
+	["operator", "="],
+	["template-string", [
+		["template-punctuation", "`"],
+		["string", "this is fine"],
+		["template-punctuation", "`"]
+	]],
+	["punctuation", ";"],
+
+	["comment", "// `load bearing comment`"],
+
+	["keyword", "const"],
+	" var3 ",
+	["operator", "="],
+	["template-string", [
+		["template-punctuation", "`"],
+		["string", "break starts here"],
+		["template-punctuation", "`"]
+	]],
+	["punctuation", ";"],
+
+	["keyword", "const"],
+	" var4 ",
+	["operator", "="],
+	["template-string", [
+		["template-punctuation", "`"],
+		["string", "break ends here"],
+		["template-punctuation", "`"]
+	]],
+	["punctuation", ";"]
+]
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language javascript
: '>>>>> End Test Output'
rm -f tests/languages/javascript/issue2694.test
