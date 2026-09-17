#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 8eb707e4ea8157fb38b49ff9ef8a253a90553bec
git checkout 8eb707e4ea8157fb38b49ff9ef8a253a90553bec tests/unit/mapped-strings/mapped-text.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unit/mapped-strings/mapped-text.test.ts b/tests/unit/mapped-strings/mapped-text.test.ts
index 1a86c8ace2..8fc81f7323 100644
--- a/tests/unit/mapped-strings/mapped-text.test.ts
+++ b/tests/unit/mapped-strings/mapped-text.test.ts
@@ -5,13 +5,18 @@
 *
 */
 import { unitTest } from "../../test.ts";
-import { assert } from "testing/asserts.ts";
+import { assert, assertEquals } from "testing/asserts.ts";
 import {
   asMappedString,
   mappedDiff,
   mappedString,
 } from "../../../src/core/mapped-text.ts";
-import { mappedSubstring } from "../../../src/core/lib/mapped-text.ts";
+import {
+  mappedSubstring,
+  mappedTrim,
+  mappedTrimEnd,
+  mappedTrimStart,
+} from "../../../src/core/lib/mapped-text.ts";
 
 // deno-lint-ignore require-await
 unitTest("mapped-text - mappedString()", async () => {
@@ -188,3 +193,28 @@ viewof x = Inputs.range([0, 100], label = "hello!", value = 20)
 
   mappedDiff(asMappedString(text1), text2);
 });
+
+// deno-lint-ignore require-await
+unitTest("mapped-text - mappedTrim{,Start,End}()", async () => {
+  const whitespace = "\u000A\u000D\u2028\u2029\u0009\u000B\u000C\uFEFF \t";
+  const content = "a \n";
+  for (let i = 0; i < 1000; ++i) {
+    const startTrimLength = Math.random() * 10;
+    const endTrimLength = Math.random() * 10;
+    const contentLength = Math.random() * 10;
+    const strContent = [];
+    for (let j = 0; j < startTrimLength; ++j) {
+      strContent.push(whitespace[~~(Math.random() * whitespace.length)]);
+    }
+    for (let j = 0; j < contentLength; ++j) {
+      strContent.push(content[~~(Math.random() * content.length)]);
+    }
+    for (let j = 0; j < endTrimLength; ++j) {
+      strContent.push(whitespace[~~(Math.random() * whitespace.length)]);
+    }
+    const mappedStr = asMappedString(strContent.join(""));
+    assertEquals(mappedTrim(mappedStr).value, mappedStr.value.trim());
+    assertEquals(mappedTrimStart(mappedStr).value, mappedStr.value.trimStart());
+    assertEquals(mappedTrimEnd(mappedStr).value, mappedStr.value.trimEnd());
+  }
+});

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
git checkout 8eb707e4ea8157fb38b49ff9ef8a253a90553bec tests/unit/mapped-strings/mapped-text.test.ts
