#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 657c02e77bcf1764e462ef130e09b75411635593
rm -f tests/docs/smoke-all/2023/08/30/6658.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/08/30/6658.qmd b/tests/docs/smoke-all/2023/08/30/6658.qmd
new file mode 100644
index 0000000000..81139c9183
--- /dev/null
+++ b/tests/docs/smoke-all/2023/08/30/6658.qmd
@@ -0,0 +1,19 @@
+---
+format: html
+_quarto:
+  tests:
+    html:
+      ensureHtmlElements:
+        - ["img"]
+        - ["figcaption"]
+---
+
+Having empty caption with knitr chunk can happen when defining caption from within the chunk. (when leveraging `eval.after`)
+
+See https://github.com/quarto-dev/quarto-cli/issues/6658
+
+```{r}
+#| fig-cap: !expr caption
+caption = character(0)
+knitr::include_graphics("https://quarto.org/quarto.png")
+```
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/08/30/6658.qmd
