#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 344d0b27d2a3b1d955be100a2bbe7da720aa8ff2
rm -f tests/languages/sql/identifier_feature.test tests/languages/sql/issue3140.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/sql/identifier_feature.test b/tests/languages/sql/identifier_feature.test
new file mode 100644
index 0000000000..c79145772b
--- /dev/null
+++ b/tests/languages/sql/identifier_feature.test
@@ -0,0 +1,41 @@
+`5Customers`
+`tableName~`
+` SELECT `
+foo.`GROUP`
+`a``b`
+
+----------------------------------------------------
+
+[
+	["identifier", [
+		["punctuation", "`"],
+		"5Customers",
+		["punctuation", "`"]
+	]],
+
+	["identifier", [
+		["punctuation", "`"],
+		"tableName~",
+		["punctuation", "`"]
+	]],
+
+	["identifier", [
+		["punctuation", "`"],
+		" SELECT ",
+		["punctuation", "`"]
+	]],
+
+	"\r\nfoo",
+	["punctuation", "."],
+	["identifier", [
+		["punctuation", "`"],
+		"GROUP",
+		["punctuation", "`"]
+	]],
+
+	["identifier", [
+		["punctuation", "`"],
+		"a``b",
+		["punctuation", "`"]
+	]]
+]
diff --git a/tests/languages/sql/issue3140.test b/tests/languages/sql/issue3140.test
new file mode 100644
index 0000000000..0f969c7a67
--- /dev/null
+++ b/tests/languages/sql/issue3140.test
@@ -0,0 +1,72 @@
+select
+   `t`.`col1`, `t`.`col2`, `t`.`col3`, `t`.`col4`
+from
+   `test_table` as `t`
+
+----------------------------------------------------
+
+[
+	["keyword", "select"],
+
+	["identifier", [
+		["punctuation", "`"],
+		"t",
+		["punctuation", "`"]
+	]],
+	["punctuation", "."],
+	["identifier", [
+		["punctuation", "`"],
+		"col1",
+		["punctuation", "`"]
+	]],
+	["punctuation", ","],
+	["identifier", [
+		["punctuation", "`"],
+		"t",
+		["punctuation", "`"]
+	]],
+	["punctuation", "."],
+	["identifier", [
+		["punctuation", "`"],
+		"col2",
+		["punctuation", "`"]
+	]],
+	["punctuation", ","],
+	["identifier", [
+		["punctuation", "`"],
+		"t",
+		["punctuation", "`"]
+	]],
+	["punctuation", "."],
+	["identifier", [
+		["punctuation", "`"],
+		"col3",
+		["punctuation", "`"]
+	]],
+	["punctuation", ","],
+	["identifier", [
+		["punctuation", "`"],
+		"t",
+		["punctuation", "`"]
+	]],
+	["punctuation", "."],
+	["identifier", [
+		["punctuation", "`"],
+		"col4",
+		["punctuation", "`"]
+	]],
+
+	["keyword", "from"],
+
+	["identifier", [
+		["punctuation", "`"],
+		"test_table",
+		["punctuation", "`"]
+	]],
+	["keyword", "as"],
+	["identifier", [
+		["punctuation", "`"],
+		"t",
+		["punctuation", "`"]
+	]]
+]

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language sql
: '>>>>> End Test Output'
rm -f tests/languages/sql/identifier_feature.test tests/languages/sql/issue3140.test
