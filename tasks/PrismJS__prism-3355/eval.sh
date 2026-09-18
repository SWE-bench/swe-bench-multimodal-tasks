#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
export npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0
git status
git show
git -c core.fileMode=false diff ead22e1e03f87319ceb20c712e6424c55276c887
git checkout ead22e1e03f87319ceb20c712e6424c55276c887 tests/languages/cshtml/block_feature.test && rm -f tests/languages/cshtml/issue3354.test
git apply -v - <<'EOF_114329324912'
diff --git a/tests/languages/cshtml/block_feature.test b/tests/languages/cshtml/block_feature.test
index 59bd8b05de..e3d1875316 100644
--- a/tests/languages/cshtml/block_feature.test
+++ b/tests/languages/cshtml/block_feature.test
@@ -94,6 +94,10 @@ finally
     // Do critical section work
 }
 
+@helper TrialHelper(string name) {
+    // some code
+}
+
 ----------------------------------------------------
 
 [
@@ -893,6 +897,24 @@ finally
 			["punctuation", "("], "SomeLock", ["punctuation", ")"],
 			["punctuation", "{"],
 			["comment", "// Do critical section work"],
+			["punctuation", "}"]
+		]]
+	]],
+
+	["block", [
+		["keyword", "@helper"],
+		["csharp", [
+			["function", "TrialHelper"],
+			["punctuation", "("],
+			["class-name", [
+				["keyword", "string"]
+			]],
+			" name",
+			["punctuation", ")"],
+			["punctuation", "{"],
+
+			["comment", "// some code"],
+
 			["punctuation", "}"]
 		]]
 	]]
diff --git a/tests/languages/cshtml/issue3354.test b/tests/languages/cshtml/issue3354.test
new file mode 100644
index 0000000000..8b27f99005
--- /dev/null
+++ b/tests/languages/cshtml/issue3354.test
@@ -0,0 +1,194 @@
+<input type="text" placeholder="@Localize.GetLabelHtml("PLACEHOLDER")"/>
+
+<h1>
+    @Localize.GetLabelHtml("TITLE")
+</h1>
+
+@{
+    var man = "Federico";
+    var text = string.Concat("Nice to meet you", " ", man);
+}
+
+@helper TrialHelper(string name) {
+    var text = string.Concat("Hello", " ", name);
+    <h1>
+        @(text + ", how's going?")
+    </h1>
+    <p>
+        Hello World!
+    </p>
+}
+
+----------------------------------------------------
+
+[
+	["tag", [
+		["tag", [
+			["punctuation", "<"],
+			"input"
+		]],
+		["attr-name", ["type"]],
+		["attr-value", [
+			["punctuation", "="],
+			["punctuation", "\""],
+			"text",
+			["punctuation", "\""]
+		]],
+		["attr-name", ["placeholder"]],
+		["attr-value", [
+			["punctuation", "="],
+			["punctuation", "\""],
+			["value", [
+				["keyword", "@"],
+				["csharp", [
+					"Localize",
+					["punctuation", "."],
+					["function", "GetLabelHtml"],
+					["punctuation", "("],
+					["string", "\"PLACEHOLDER\""],
+					["punctuation", ")"]
+				]]
+			]],
+			["punctuation", "\""]
+		]],
+		["punctuation", "/>"]
+	]],
+
+	["tag", [
+		["tag", [
+			["punctuation", "<"],
+			"h1"
+		]],
+		["punctuation", ">"]
+	]],
+	["value", [
+		["keyword", "@"],
+		["csharp", [
+			"Localize",
+			["punctuation", "."],
+			["function", "GetLabelHtml"],
+			["punctuation", "("],
+			["string", "\"TITLE\""],
+			["punctuation", ")"]
+		]]
+	]],
+	["tag", [
+		["tag", [
+			["punctuation", "</"],
+			"h1"
+		]],
+		["punctuation", ">"]
+	]],
+
+	["block", [
+		["keyword", "@"],
+		["csharp", [
+			["punctuation", "{"],
+
+			["class-name", [
+				["keyword", "var"]
+			]],
+			" man ",
+			["operator", "="],
+			["string", "\"Federico\""],
+			["punctuation", ";"],
+
+			["class-name", [
+				["keyword", "var"]
+			]],
+			" text ",
+			["operator", "="],
+			["keyword", "string"],
+			["punctuation", "."],
+			["function", "Concat"],
+			["punctuation", "("],
+			["string", "\"Nice to meet you\""],
+			["punctuation", ","],
+			["string", "\" \""],
+			["punctuation", ","],
+			" man",
+			["punctuation", ")"],
+			["punctuation", ";"],
+
+			["punctuation", "}"]
+		]]
+	]],
+
+	["block", [
+		["keyword", "@helper"],
+		["csharp", [
+			["function", "TrialHelper"],
+			["punctuation", "("],
+			["class-name", [
+				["keyword", "string"]
+			]],
+			" name",
+			["punctuation", ")"],
+			["punctuation", "{"],
+
+			["class-name", [
+				["keyword", "var"]
+			]],
+			" text ",
+			["operator", "="],
+			["keyword", "string"],
+			["punctuation", "."],
+			["function", "Concat"],
+			["punctuation", "("],
+			["string", "\"Hello\""],
+			["punctuation", ","],
+			["string", "\" \""],
+			["punctuation", ","],
+			" name",
+			["punctuation", ")"],
+			["punctuation", ";"],
+
+			["html", [
+				["tag", [
+					["tag", [
+						["punctuation", "<"],
+						"h1"
+					]],
+					["punctuation", ">"]
+				]],
+				["value", [
+					["keyword", "@"],
+					["csharp", [
+						["punctuation", "("],
+						"text ",
+						["operator", "+"],
+						["string", "\", how's going?\""],
+						["punctuation", ")"]
+					]]
+				]],
+				["tag", [
+					["tag", [
+						["punctuation", "</"],
+						"h1"
+					]],
+					["punctuation", ">"]
+				]]
+			]],
+
+			["html", [
+				["tag", [
+					["tag", [
+						["punctuation", "<"],
+						"p"
+					]],
+					["punctuation", ">"]
+				]],
+				"\r\n        Hello World!\r\n    ",
+				["tag", [
+					["tag", [
+						["punctuation", "</"],
+						"p"
+					]],
+					["punctuation", ">"]
+				]]
+			]],
+
+			["punctuation", "}"]
+		]]
+	]]
+]

EOF_114329324912
if ! git -c core.fileMode=false diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing from the image cache"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true CHROMEDRIVER_SKIP_DOWNLOAD=true npm_config_offline=true npm_config_audit=false npm_config_fund=false YARN_ENABLE_NETWORK=0; if [ -d /run/swebench-offline/npm ]; then export npm_config_cache=/run/swebench-offline/npm; fi; if [ -d /run/swebench-offline/yarn ]; then export YARN_CACHE_FOLDER=/run/swebench-offline/yarn; fi; if [ -f yarn.lock ]; then case "$(yarn --version)" in 0.*|1.*) timeout 900 yarn install --offline --frozen-lockfile --ignore-scripts --non-interactive --silent > /dev/null 2>&1;; *) timeout 900 yarn install --immutable-cache --mode=skip-builds > /dev/null 2>&1;; esac; else timeout 900 npm install --offline --legacy-peer-deps --ignore-scripts --no-audit --no-fund --silent > /dev/null 2>&1; fi || { echo "offline dependency re-sync failed: image cache is incomplete" >&2; exit 1; }; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/mocha tests/run.js --reporter json --language cshtml
: '>>>>> End Test Output'
git checkout ead22e1e03f87319ceb20c712e6424c55276c887 tests/languages/cshtml/block_feature.test && rm -f tests/languages/cshtml/issue3354.test
