#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff e4660ef375dd6d6b176301a52a0c73cf3ee775e2
rm -f tests/docs/smoke-all/2023/02/25/issue-4316.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/02/25/issue-4316.qmd b/tests/docs/smoke-all/2023/02/25/issue-4316.qmd
new file mode 100644
index 0000000000..89a60f28a6
--- /dev/null
+++ b/tests/docs/smoke-all/2023/02/25/issue-4316.qmd
@@ -0,0 +1,34 @@
+---
+format: html
+_quarto:
+  tests:
+    html:
+      ensureHtmlElements:
+        - ["th[colspan=\"2\"]"]
+        - []
+---
+
+```{r}
+#| include: false
+library(gt)
+```
+
+```{r}
+#| echo: false
+#| tbl-cap: "Caption"
+#| label: tbl-test
+dat <- data.frame(
+  a = c("A", "B"),
+  x = c(1, 2), 
+  y = c(12, 9), 
+  z = c(13, 11))
+
+dat %>%
+  gt() %>%
+  tab_spanner(
+	label = "Subheader",
+	columns = c(x, y)
+  )
+```
+
+@tbl-test
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/02/25/issue-4316.qmd
