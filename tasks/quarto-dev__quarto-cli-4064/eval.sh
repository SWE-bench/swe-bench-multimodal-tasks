#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff e2fbed9afac5c893088ae78f4473f2677529656f
rm -f tests/docs/smoke-all/2023/01/23/reveal-config-quote-4063.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/01/23/reveal-config-quote-4063.qmd b/tests/docs/smoke-all/2023/01/23/reveal-config-quote-4063.qmd
new file mode 100644
index 0000000000..17ad621a81
--- /dev/null
+++ b/tests/docs/smoke-all/2023/01/23/reveal-config-quote-4063.qmd
@@ -0,0 +1,14 @@
+---
+format: 
+  revealjs:
+    width: 5.3%
+    height: 53%
+_quarto:
+  tests:
+    revealjs:
+      ensureFileRegexMatches:
+        - ["width: '5\\.3%',", "height: '53%',"]
+        - ["width: 5\\.3%,", "height: 53%,"]
+---
+
+# Slide
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/01/23/reveal-config-quote-4063.qmd
