#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 6f4599c36bb0c309a5ba5fc3247abd6ac82cc434
rm -f tests/docs/smoke-all/2023/02/01/4174.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/02/01/4174.qmd b/tests/docs/smoke-all/2023/02/01/4174.qmd
new file mode 100644
index 0000000000..65bd308e73
--- /dev/null
+++ b/tests/docs/smoke-all/2023/02/01/4174.qmd
@@ -0,0 +1,18 @@
+---
+title: "issue #4174"
+format: html
+_quarto:
+  tests:
+    html:
+      ensureHtmlElements:
+        - []
+        - ["h2.anchored"]
+---
+
+:::{.panel-tabset .nav-fill}
+
+## A
+
+## B
+
+:::

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/02/01/4174.qmd
