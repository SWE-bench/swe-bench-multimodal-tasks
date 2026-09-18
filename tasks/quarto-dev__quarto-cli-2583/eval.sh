#!/bin/bash
exec 2>&1
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
source $NVM_DIR/nvm.sh
git status
git show
git -c core.fileMode=false diff 8222a0184071bf735cbee0a6300a813ab6bc6014
rm -f tests/docs/smoke-all/2023/01/16/md-captions.qmd
git apply -v - <<'EOF_114329324912'
diff --git a/tests/docs/smoke-all/2023/01/16/md-captions.qmd b/tests/docs/smoke-all/2023/01/16/md-captions.qmd
new file mode 100644
index 0000000000..d170ddffad
--- /dev/null
+++ b/tests/docs/smoke-all/2023/01/16/md-captions.qmd
@@ -0,0 +1,46 @@
+---
+title: markdown in captions
+format:
+  html: default
+  latex: default
+_quarto:
+  tests: 
+    html:
+      ensureHtmlElements:
+        - ["#html caption sup", "#html caption em", "#paged div.table-caption sup", "#paged div.table-caption em", "#md caption sup"]
+    latex:
+      ensureFileRegexMatches:
+        - ["\\\\textsuperscript\\{superscript\\}", "\\\\emph\\{italics\\}"]
+execute: 
+  echo: false
+---
+
+# HTML table {#html}
+```{r}
+#| tbl-cap: Using ^superscript^ or _italics_ in table caption
+#| eval: !expr knitr::is_html_output()
+knitr::kable(head(cars), format = "html")
+```
+
+# Paged table {#paged}
+
+```{r}
+#| tbl-cap: Using ^superscript^ or _italics_ in table caption
+#| eval: !expr knitr::is_html_output()
+rmarkdown::paged_table(head(cars))
+```
+
+# Mardown Table {#md}
+
+```{r}
+#| tbl-cap: Using ^superscript^ in caption
+knitr::kable(head(cars))
+```
+
+# LaTeX table {#latex}
+
+```{r}
+#| tbl-cap: Using _italics_ in caption
+#| eval: !expr knitr::is_latex_output()
+knitr::kable(head(cars), format = "latex")
+```
\ No newline at end of file

EOF_114329324912
if ! git diff --quiet HEAD -- package.json 2>/dev/null; then echo "package.json changed by patch; re-syncing dependencies"; export PUPPETEER_SKIP_DOWNLOAD=true PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true; if [ -f yarn.lock ]; then timeout 900 yarn install --silent > /dev/null 2>&1 || true; else timeout 900 npm install --silent > /dev/null 2>&1 || true; fi; chmod -R a+rX node_modules > /dev/null 2>&1 || true; fi
: '>>>>> Start Test Output'
cp -r tests/ tests_tmp/ ; cd tests ; QUARTO_TESTS_NO_CONFIG="true" ./run-tests.sh ; cd .. ; rm -rf tests/ ; mv tests_tmp/ tests/
: '>>>>> End Test Output'
rm -f tests/docs/smoke-all/2023/01/16/md-captions.qmd
