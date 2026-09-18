#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 729fcd308b214f4624a9e17bf167562a32a0624a
rm -f tests/docs/smoke-all/2023/07/31/4057.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/07/31/4057.qmd b/tests/docs/smoke-all/2023/07/31/4057.qmd
new file mode 100644
index 0000000000..504c1564ee
--- /dev/null
+++ b/tests/docs/smoke-all/2023/07/31/4057.qmd
@@ -0,0 +1,19 @@
+---
+title: Do not trim spaces in code output
+format: html
+_quarto:
+  tests:
+    html:
+      ensureHtmlElements:
+        - ['div.cell-output-display > ul > li:nth-child(4)']
+        - ['div.cell-output-display > ul > li > ul']
+---
+
+Should output as a list of one level not two. First spaces should not be trimmed. 
+
+```{r}
+knitr::asis_output(
+  paste0(c("", "  * 1", "  * 2", "  * _3_", "  * _1_ and _2_", "", 
+"<!-- end of list -->", ""), collapse = "\n")
+)
+```
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/07/31/4057.qmd
