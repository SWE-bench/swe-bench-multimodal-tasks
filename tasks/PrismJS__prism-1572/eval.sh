#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff 225dd3f7316ad8a18454aee499795433656c1615
rm -f tests/languages/gcode/checksum_feature.test tests/languages/gcode/comment_feature.test tests/languages/gcode/keyword_feature.test tests/languages/gcode/property_feature.test tests/languages/gcode/string_feature.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/gcode/checksum_feature.test b/tests/languages/gcode/checksum_feature.test
new file mode 100644
index 0000000000..d3ea45613a
--- /dev/null
+++ b/tests/languages/gcode/checksum_feature.test
@@ -0,0 +1,12 @@
+G28*22
+
+----------------------------------------------------
+
+[
+	["keyword", "G28"],
+	["checksum", "*22"]
+]
+
+----------------------------------------------------
+
+Checks for checksums.
diff --git a/tests/languages/gcode/comment_feature.test b/tests/languages/gcode/comment_feature.test
new file mode 100644
index 0000000000..cb2533f895
--- /dev/null
+++ b/tests/languages/gcode/comment_feature.test
@@ -0,0 +1,20 @@
+; foo
+(Home some axes)
+G28 (here come the axes to be homed) X
+
+----------------------------------------------------
+
+[
+	["comment", "; foo"],
+
+	["comment", "(Home some axes)"],
+
+	["keyword", "G28"],
+	["comment", "(here come the axes to be homed)"],
+	["property", "X"]
+
+]
+
+----------------------------------------------------
+
+Checks for comments.
diff --git a/tests/languages/gcode/keyword_feature.test b/tests/languages/gcode/keyword_feature.test
new file mode 100644
index 0000000000..d72d0760b2
--- /dev/null
+++ b/tests/languages/gcode/keyword_feature.test
@@ -0,0 +1,23 @@
+G00
+G200
+G84.1
+
+M00
+M123
+M52.4
+
+----------------------------------------------------
+
+[
+	["keyword", "G00"],
+	["keyword", "G200"],
+	["keyword", "G84.1"],
+
+	["keyword", "M00"],
+	["keyword", "M123"],
+	["keyword", "M52.4"]
+]
+
+----------------------------------------------------
+
+Checks for G- and M-codes.
diff --git a/tests/languages/gcode/property_feature.test b/tests/languages/gcode/property_feature.test
new file mode 100644
index 0000000000..9dee88682d
--- /dev/null
+++ b/tests/languages/gcode/property_feature.test
@@ -0,0 +1,17 @@
+X123
+Y0.2
+Z-3.1415
+E420:420
+
+----------------------------------------------------
+
+[
+	["property", "X"], "123\n",
+	["property", "Y"], "0.2\n",
+	["property", "Z"], "-3.1415\n",
+	["property", "E"], "420", ["punctuation", ":"], "420"
+]
+
+----------------------------------------------------
+
+Checks for all other codes except G- and M-codes.
diff --git a/tests/languages/gcode/string_feature.test b/tests/languages/gcode/string_feature.test
new file mode 100644
index 0000000000..d05306d7db
--- /dev/null
+++ b/tests/languages/gcode/string_feature.test
@@ -0,0 +1,17 @@
+M587 S"MYROUTER" P"ABCxyz;"" 123"
+
+----------------------------------------------------
+
+[
+	["keyword", "M587"],
+
+	["property", "S"],
+	["string", "\"MYROUTER\""],
+
+	["property", "P"],
+	["string", "\"ABCxyz;\"\" 123\""]
+]
+
+----------------------------------------------------
+
+Checks for strings.

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language gcode
: '>>>>> End Test Output'
rm -f tests/languages/gcode/checksum_feature.test tests/languages/gcode/comment_feature.test tests/languages/gcode/keyword_feature.test tests/languages/gcode/property_feature.test tests/languages/gcode/string_feature.test
