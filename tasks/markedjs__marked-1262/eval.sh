#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 579f7bfb562bdeeaf0ee98deaba5a8334f9602d1
git checkout 579f7bfb562bdeeaf0ee98deaba5a8334f9602d1 test/specs/marked/marked-spec.js test/specs/marked/marked.json
git apply -v - <<'EOF_114329324912'
diff --git a/test/specs/marked/marked-spec.js b/test/specs/marked/marked-spec.js
index 6a314273b1..5d4d32e91c 100644
--- a/test/specs/marked/marked-spec.js
+++ b/test/specs/marked/marked-spec.js
@@ -46,3 +46,18 @@ describe('Marked Code spans', function() {
     messenger.test(spec, section, ignore);
   });
 });
+
+describe('Marked Table cells', function() {
+  var section = 'Table cells';
+
+  // var shouldPassButFails = [];
+  var shouldPassButFails = [];
+
+  var willNotBeAttemptedByCoreTeam = [];
+
+  var ignore = shouldPassButFails.concat(willNotBeAttemptedByCoreTeam);
+
+  markedSpec.forEach(function(spec) {
+    messenger.test(spec, section, ignore);
+  });
+});
diff --git a/test/specs/marked/marked.json b/test/specs/marked/marked.json
index eedb65a83a..60c2023827 100644
--- a/test/specs/marked/marked.json
+++ b/test/specs/marked/marked.json
@@ -2,7 +2,55 @@
   {
     "section": "Code spans",
     "markdown": "`someone@example.com`",
-    "html": "<p><code>someone@exmaple.com</code></p>\n",
+    "html": "<p><code>someone@example.com</code></p>",
     "example": 1
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|\n|-|\n|1|",
+    "html": "<table><thead><tr><th>1</th></tr></thead><tbody><tr><td>1</td></tr></tbody></table>",
+    "example": 2
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|\n|-|\n|\\||",
+    "html": "<table><thead><tr><th>1</th></tr></thead><tbody><tr><td>|</td></tr></tbody></table>",
+    "example": 3
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|\n|-|\n|1\\\\1|",
+    "html": "<table><thead><tr><th>1</th></tr></thead><tbody><tr><td>1\\1</td></tr></tbody></table>",
+    "example": 4
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|\n|-|\n|\\\\\\\\||",
+    "html": "<table><thead><tr><th>1</th></tr></thead><tbody><tr><td>\\\\</td></tr></tbody></table>",
+    "example": 5
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|\n|-|\n|\\\\\\\\\\||",
+    "html": "<table><thead><tr><th>1</th></tr></thead><tbody><tr><td>\\\\|</td></tr></tbody></table>",
+    "example": 6
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|2|\n|-|-|\n||2|",
+    "html": "<table><thead><tr><th>1</th><th>2</th></tr></thead><tbody><tr><td></td><td>2</td></tr></tbody></table>",
+    "example": 7
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|2|\n|-|-|\n|1\\|\\\\|2\\|\\\\|",
+    "html": "<table><thead><tr><th>1</th><th>2</th></tr></thead><tbody><tr><td>1|\\</td><td>2|\\</td></tr></tbody></table>",
+    "example": 8
+  },
+  {
+    "section": "Table cells",
+    "markdown": "|1|2|\n|-|-|\n| |2|",
+    "html": "<table><thead><tr><th>1</th><th>2</th></tr></thead><tbody><tr><td></td><td>2</td></tr></tbody></table>",
+    "example": 9
   }
 ]

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
./node_modules/.bin/jasmine --no-color --config=jasmine.json
: '>>>>> End Test Output'
git checkout 579f7bfb562bdeeaf0ee98deaba5a8334f9602d1 test/specs/marked/marked-spec.js test/specs/marked/marked.json
