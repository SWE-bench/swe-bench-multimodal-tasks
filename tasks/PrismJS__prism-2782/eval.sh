#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 42d24fa2607df63aacfc7dbdcc99b458d4656cf2
rm -f tests/languages/vbnet/issue2781.test tests/languages/vbnet/punctuation_feature.test tests/languages/vbnet/string_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/vbnet/issue2781.test b/tests/languages/vbnet/issue2781.test
new file mode 100644
index 0000000000..4e8441bf8d
--- /dev/null
+++ b/tests/languages/vbnet/issue2781.test
@@ -0,0 +1,24 @@
+bob = new SqlCommand("Select * from test Where Code=@Code");
+bob = new SqlCommand("Select * from test Where Code=Code");
+
+----------------------------------------------------
+
+[
+	"bob ",
+	["operator", "="],
+	["keyword", "new"],
+	" SqlCommand",
+	["punctuation", "("],
+	["string", "\"Select * from test Where Code=@Code\""],
+	["punctuation", ")"],
+	["punctuation", ";"],
+
+	"\nbob ",
+	["operator", "="],
+	["keyword", "new"],
+	" SqlCommand",
+	["punctuation", "("],
+	["string", "\"Select * from test Where Code=Code\""],
+	["punctuation", ")"],
+	["punctuation", ";"]
+]
\ No newline at end of file
diff --git a/tests/languages/vbnet/punctuation_feature.test b/tests/languages/vbnet/punctuation_feature.test
new file mode 100644
index 0000000000..762103bc35
--- /dev/null
+++ b/tests/languages/vbnet/punctuation_feature.test
@@ -0,0 +1,15 @@
+, ; :
+( ) { }
+
+----------------------------------------------------
+
+[
+	["punctuation", ","],
+	["punctuation", ";"],
+	["punctuation", ":"],
+
+	["punctuation", "("],
+	["punctuation", ")"],
+	["punctuation", "{"],
+	["punctuation", "}"]
+]
\ No newline at end of file
diff --git a/tests/languages/vbnet/string_feature.test b/tests/languages/vbnet/string_feature.test
new file mode 100644
index 0000000000..4cb31fe4f0
--- /dev/null
+++ b/tests/languages/vbnet/string_feature.test
@@ -0,0 +1,17 @@
+Dim x = "hello
+world"
+
+Console.WriteLine("Message: {0}", message)
+
+----------------------------------------------------
+
+[
+	["keyword", "Dim"], " x ", ["operator", "="], ["string", "\"hello\nworld\""],
+
+	"\n\nConsole.WriteLine",
+	["punctuation", "("],
+	["string", "\"Message: {0}\""],
+	["punctuation", ","],
+	" message",
+	["punctuation", ")"]
+]
\ No newline at end of file

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language vbnet
: '>>>>> End Test Output'
rm -f tests/languages/vbnet/issue2781.test tests/languages/vbnet/punctuation_feature.test tests/languages/vbnet/string_feature.test
